# Práctica — Policy Evaluation Logic (Allow)

## Enunciado de la tarea

> Explore the process of evaluating policies and configure both an identity-based policy and a resource-based policy for a specific role.

**Región:** `eu-west-1`

**Recursos de la tarea** (ya provisionados por el sandbox):
- IAM Role: `cmtr-iacp1ebx-iam-pela-iam_role`
- S3 Bucket 1: `cmtr-iacp1ebx-iam-pela-bucket-1-7415380` — configuración por defecto, un objeto adentro, **sin política previa**
- S3 Bucket 2: `cmtr-iacp1ebx-iam-pela-bucket-2-7415380` — vacío, solo para verificación, **no tocar**

**Objetivos (2 movimientos):**
1. Política inline en el rol que permita listar todos los buckets.
2. Política de bucket (resource-based) en el bucket 1 que permita `GetObject`/`PutObject`/`ListBucket` **solo** para ese rol (no para todos los principals) y **solo** sobre ese bucket.

**Entorno real usado:** sandbox AWS, cuenta `863518426750`. Trabajé por **CLI**.

---

## Movimiento 1 — Política inline: listar todos los buckets

```bash
cat > list-buckets-policy.json << EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "s3:ListAllMyBuckets",
      "Resource": "*"
    }
  ]
}
EOF

aws iam put-role-policy \
  --role-name cmtr-iacp1ebx-iam-pela-iam_role \
  --policy-name list-all-buckets-policy \
  --policy-document file://list-buckets-policy.json \
  --region eu-west-1
```

## Movimiento 2 — Política del bucket 1 (Allow acotado al rol, sin tocar bucket 2)

```bash
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

cat > bucket1-policy.json << EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowPelaRoleOnly",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::${ACCOUNT_ID}:role/cmtr-iacp1ebx-iam-pela-iam_role"
      },
      "Action": ["s3:GetObject", "s3:PutObject", "s3:ListBucket"],
      "Resource": [
        "arn:aws:s3:::cmtr-iacp1ebx-iam-pela-bucket-1-7415380",
        "arn:aws:s3:::cmtr-iacp1ebx-iam-pela-bucket-1-7415380/*"
      ]
    }
  ]
}
EOF

aws s3api put-bucket-policy \
  --bucket cmtr-iacp1ebx-iam-pela-bucket-1-7415380 \
  --policy file://bucket1-policy.json
```

Puntos clave respetados: `Principal` acotado al ARN exacto del rol (no `"*"` — cumple "do not allow access to all principals"), `Resource` incluye tanto el ARN del bucket (necesario para `ListBucket`, que opera sobre el bucket en sí) como `bucket/*` (necesario para `GetObject`/`PutObject`, que operan sobre objetos). **Bucket 2 no se tocó en absoluto.**

## Verificación — asumiendo el rol directamente

```bash
CREDS=$(aws sts assume-role \
  --role-arn arn:aws:iam::863518426750:role/cmtr-iacp1ebx-iam-pela-iam_role \
  --role-session-name test-pela \
  --query 'Credentials' --output json)

export AWS_ACCESS_KEY_ID=$(echo $CREDS | jq -r '.AccessKeyId')
export AWS_SECRET_ACCESS_KEY=$(echo $CREDS | jq -r '.SecretAccessKey')
export AWS_SESSION_TOKEN=$(echo $CREDS | jq -r '.SessionToken')

aws s3 ls
# cmtr-iacp1ebx-iam-pela-bucket-1-7415380
# cmtr-iacp1ebx-iam-pela-bucket-2-7415380   (ListAllMyBuckets es de alcance global, lista TODOS los nombres —
#                                              no implica poder ver el CONTENIDO de cada uno)

aws s3 ls s3://cmtr-iacp1ebx-iam-pela-bucket-1-7415380
# 2026-08-26 00:41:07    1898182 image.png    → funciona

aws s3 ls s3://cmtr-iacp1ebx-iam-pela-bucket-2-7415380
# AccessDenied: ... s3:ListBucket ... because no identity-based policy allows the s3:ListBucket action
```

**Punto sutil a notar**: `aws s3 ls` (sin argumentos) SÍ muestra el nombre de `bucket-2` en el listado — eso es esperado y correcto, porque `s3:ListAllMyBuckets` es una acción de alcance global que no distingue por bucket. Lo que está bloqueado es **listar el contenido** de `bucket-2` (`s3:ListBucket` sobre ese bucket específico), que es una acción y un alcance completamente distintos.

No olvidar recargar las credenciales originales del sandbox después de la prueba (se quedó operando con la sesión asumida del rol).
