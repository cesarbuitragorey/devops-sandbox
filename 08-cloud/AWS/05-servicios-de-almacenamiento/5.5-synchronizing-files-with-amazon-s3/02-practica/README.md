# Práctica — Synchronizing Files with Amazon S3

## Enunciado de la tarea

> Configure file synchronization and cross-region replication between two S3 buckets using an EC2 instance, syncing a local directory to the primary bucket every minute via cron.

**Regiones:** primaria `eu-west-1`, secundaria `us-east-1` — Cuenta `476114144911`

**Recursos de la tarea:**
- EC2 `i-0184dfec1235a9792` (Amazon Linux 2023, `eu-west-1`), con `/home/ec2-user/sync_s3.log` pre-creado
- Rol EC2 `cmtr-iacp1ebx-s3-s-iam_role`
- Rol de replicación (pre-creado) `s3crr_role_for_cmtr-iacp1ebx-s3-s-bucket-297591-backup-primary`
- Bucket primario `cmtr-iacp1ebx-s3-s-bucket-297591-backup-primary` (`eu-west-1`)
- Bucket secundario `cmtr-iacp1ebx-s3-s-bucket-4892568-backup-secondary` (`us-east-1`)

**Objetivos (4 grandes pasos):**
1. Política administrada por el cliente (no inline) con permisos mínimos, adjunta al rol EC2.
2. Versionado + lifecycle en ambos buckets (3 versiones primario, 5 secundario).
3. Cross-Region Replication primario → secundario.
4. Cron job en `ec2-user` sincronizando `/backups` cada minuto, log en `sync_s3.log`.

**Entorno real usado:** trabajado por **CLI** en CloudShell + Session Manager.

---

## Movimiento 1 — Política customer-managed con permisos mínimos

```bash
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

cat > s3-sync-policy.json << 'EOF'
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "s3:ListBucket",
      "Resource": "arn:aws:s3:::cmtr-iacp1ebx-s3-s-bucket-297591-backup-primary"
    },
    {
      "Effect": "Allow",
      "Action": ["s3:PutObject", "s3:GetObject"],
      "Resource": "arn:aws:s3:::cmtr-iacp1ebx-s3-s-bucket-297591-backup-primary/*"
    }
  ]
}
EOF

POLICY_ARN=$(aws iam create-policy \
  --policy-name cmtr-iacp1ebx-s3-sync-policy \
  --policy-document file://s3-sync-policy.json \
  --query 'Policy.Arn' --output text)

aws iam attach-role-policy \
  --role-name cmtr-iacp1ebx-s3-s-iam_role \
  --policy-arn $POLICY_ARN
```
Nótese: `s3:ListBucket` va con `Resource` = el ARN del **bucket** (sin `/*`, es una acción a nivel de bucket), mientras que `PutObject`/`GetObject` van con `Resource` = el ARN del bucket **+ `/*`** (acciones a nivel de objeto) — mezclar esto (ej. dar `ListBucket` sobre `/*`) no funciona porque son tipos de recurso distintos en el modelo de permisos de S3.

## Movimiento 2 — Versionado + Lifecycle en ambos buckets

```bash
aws s3api put-bucket-versioning --bucket cmtr-iacp1ebx-s3-s-bucket-297591-backup-primary --versioning-configuration Status=Enabled --region eu-west-1
aws s3api put-bucket-versioning --bucket cmtr-iacp1ebx-s3-s-bucket-4892568-backup-secondary --versioning-configuration Status=Enabled --region us-east-1
```

### Incidente: `MalformedXML` con `NewerNoncurrentVersions` solo

Primer intento (sin `NoncurrentDays`):
```json
"NoncurrentVersionExpiration": {"NewerNoncurrentVersions": 3}
```
```
An error occurred (MalformedXML) when calling the PutBucketLifecycleConfiguration operation:
The XML you provided was not well-formed or did not validate against our published schema
```
El mensaje de error no señala la causa real. **Fix**: agregar `NoncurrentDays` (aunque sea `1`) junto a `NewerNoncurrentVersions` — S3 exige ambos campos combinados, no permite usar `NewerNoncurrentVersions` de forma aislada.

```bash
cat > lifecycle-primary.json << 'EOF'
{
  "Rules": [
    {
      "ID": "retain-3-versions",
      "Status": "Enabled",
      "Filter": {"Prefix": ""},
      "NoncurrentVersionExpiration": {
        "NoncurrentDays": 1,
        "NewerNoncurrentVersions": 3
      }
    }
  ]
}
EOF

aws s3api put-bucket-lifecycle-configuration \
  --bucket cmtr-iacp1ebx-s3-s-bucket-297591-backup-primary \
  --lifecycle-configuration file://lifecycle-primary.json \
  --region eu-west-1

cat > lifecycle-secondary.json << 'EOF'
{
  "Rules": [
    {
      "ID": "retain-5-versions",
      "Status": "Enabled",
      "Filter": {"Prefix": ""},
      "NoncurrentVersionExpiration": {
        "NoncurrentDays": 1,
        "NewerNoncurrentVersions": 5
      }
    }
  ]
}
EOF

aws s3api put-bucket-lifecycle-configuration \
  --bucket cmtr-iacp1ebx-s3-s-bucket-4892568-backup-secondary \
  --lifecycle-configuration file://lifecycle-secondary.json \
  --region us-east-1
```

## Movimiento 3 — Cross-Region Replication

Usando el rol de replicación ya pre-creado por el sandbox:

```bash
cat > replication-config.json << EOF
{
  "Role": "arn:aws:iam::${ACCOUNT_ID}:role/s3crr_role_for_cmtr-iacp1ebx-s3-s-bucket-297591-backup-primary",
  "Rules": [
    {
      "ID": "replicate-to-secondary",
      "Status": "Enabled",
      "Filter": {},
      "Priority": 1,
      "DeleteMarkerReplication": {"Status": "Disabled"},
      "Destination": {
        "Bucket": "arn:aws:s3:::cmtr-iacp1ebx-s3-s-bucket-4892568-backup-secondary"
      }
    }
  ]
}
EOF

aws s3api put-bucket-replication \
  --bucket cmtr-iacp1ebx-s3-s-bucket-297591-backup-primary \
  --replication-configuration file://replication-config.json \
  --region eu-west-1
```

## Movimiento 4 — Cron job en la instancia (vía Session Manager)

```bash
aws ssm start-session --target i-0184dfec1235a9792 --region eu-west-1
```

Dentro de la instancia:
```bash
sudo mkdir -p /backups
sudo chown ec2-user:ec2-user /backups

echo "* * * * * aws s3 sync /backups s3://cmtr-iacp1ebx-s3-s-bucket-297591-backup-primary >> /home/ec2-user/sync_s3.log 2>&1" > /tmp/cron_sync
sudo crontab -u ec2-user /tmp/cron_sync
sudo crontab -u ec2-user -l
```

### Incidente menor: comandos compuestos con `sudo` en subshell no se pegaron bien

Un primer intento usando `(sudo crontab -u ec2-user -l 2>/dev/null; echo "...") | sudo crontab -u ec2-user -` no dejó ningún cron instalado (`no crontab for ec2-user` al verificar) — probablemente un problema de cómo la terminal interpretó el comando compuesto multilinea al pegarlo. **Fix**: escribir la línea de cron a un archivo temporal (`/tmp/cron_sync`) y cargarlo con `crontab -u ec2-user <archivo>`, evitando subshells y pipes complejos en el pegado.

## Verificación

```bash
echo "archivo de prueba $(date)" | sudo -u ec2-user tee /backups/test1.txt
sleep 70
sudo cat /home/ec2-user/sync_s3.log
aws s3 ls s3://cmtr-iacp1ebx-s3-s-bucket-297591-backup-primary/
aws s3 ls s3://cmtr-iacp1ebx-s3-s-bucket-4892568-backup-secondary/ --region us-east-1
```
```
upload: ../../backups/test1.txt to s3://cmtr-iacp1ebx-s3-s-bucket-297591-backup-primary/test1.txt
2026-09-03 12:18:05         47 test1.txt   (en ambos buckets, confirmando la replicación)
```
