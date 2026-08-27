# Práctica — Protecting Data in S3 Using an AWS KMS Customer Managed Key

## Enunciado de la tarea

> Encrypt the contents of an S3 bucket using a KMS key automatically created in your account, and add a new object to the encrypted bucket. An IAM role must also be configured to work with the KMS key.

**Región:** `eu-west-1`

**Recursos de la tarea** (ya provisionados por el sandbox):
- IAM Role: `cmtr-iacp1ebx-iam-sewk-iam_role` (ya con acceso completo a IAM y S3)
- S3 Buckets: `cmtr-iacp1ebx-iam-sewk-bucket-9899147-1` (origen, con el objeto `confidential_credentials.csv`) y `...-2` (destino, a cifrar)
- KMS Key: `arn:aws:kms:eu-west-1:396608813306:key/a2188234-dfd1-4004-9424-ae693adb1051` — "solo puede usarse para cifrar objetos del bucket 2; cifrar con otra key está prohibido" (restricción ya preconfigurada, no algo que debíamos crear)

**Objetivos (el enunciado dice "en tres movimientos" pero enumera 2 — ver nota abajo):**
1. Dar al rol los permisos necesarios para trabajar con la key (sin admin completo).
2. Habilitar cifrado por defecto (SSE-KMS) en el bucket 2 con esa key.

**Entorno real usado:** sandbox AWS, cuenta `396608813306`. Trabajé por **CLI**.

---

## Nota sobre el conteo de "movimientos"

Inicialmente planeé 3 movimientos (política del rol + actualizar la key policy + cifrado del bucket), replicando el patrón identity/resource-based de los labs 2.6-2.7. Al revisar la key policy actual:

```bash
aws kms get-key-policy \
  --key-id a2188234-dfd1-4004-9424-ae693adb1051 \
  --policy-name default \
  --region eu-west-1 --output text
```
```json
{
  "Version": "2012-10-17",
  "Id": "key-default-1",
  "Statement": [{
    "Sid": "Enable IAM User Permissions",
    "Effect": "Allow",
    "Principal": {"AWS": "arn:aws:iam::396608813306:root"},
    "Action": "kms:*",
    "Resource": "*"
  }]
}
```

Ya traía el statement estándar `Enable IAM User Permissions`, que delega el control de acceso a las políticas de IAM de la cuenta. Esto significa que **no hizo falta tocar la key policy** — bastó con la política de IAM en el rol. El "tercer movimiento" del enunciado resultó ser una imprecisión, no un paso oculto adicional (confirmado después por el resultado exitoso del Check de la plataforma con solo estos 2 movimientos).

## Movimiento 1 — Política de IAM en el rol para usar la key

```bash
cat > kms-role-policy.json << EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:DescribeKey"
      ],
      "Resource": "arn:aws:kms:eu-west-1:396608813306:key/a2188234-dfd1-4004-9424-ae693adb1051"
    }
  ]
}
EOF

aws iam put-role-policy \
  --role-name cmtr-iacp1ebx-iam-sewk-iam_role \
  --policy-name kms-key-access-policy \
  --policy-document file://kms-role-policy.json
```

## Movimiento 2 — Cifrado por defecto (SSE-KMS) en el bucket 2

```bash
aws s3api put-bucket-encryption \
  --bucket cmtr-iacp1ebx-iam-sewk-bucket-9899147-2 \
  --server-side-encryption-configuration '{
    "Rules": [
      {
        "ApplyServerSideEncryptionByDefault": {
          "SSEAlgorithm": "aws:kms",
          "KMSMasterKeyID": "arn:aws:kms:eu-west-1:396608813306:key/a2188234-dfd1-4004-9424-ae693adb1051"
        },
        "BucketKeyEnabled": true
      }
    ]
  }' \
  --region eu-west-1
```

## Verificación — copiar el objeto y confirmar cifrado

```bash
aws s3 cp \
  s3://cmtr-iacp1ebx-iam-sewk-bucket-9899147-1/confidential_credentials.csv \
  s3://cmtr-iacp1ebx-iam-sewk-bucket-9899147-2/confidential_credentials.csv

aws s3api head-object \
  --bucket cmtr-iacp1ebx-iam-sewk-bucket-9899147-2 \
  --key confidential_credentials.csv \
  --query '[ServerSideEncryption,SSEKMSKeyId]'
```
```json
["aws:kms", "arn:aws:kms:eu-west-1:396608813306:key/a2188234-dfd1-4004-9424-ae693adb1051"]
```

## Descubrimiento vía el Check de la plataforma: restricción de "otra key" ya preexistente

El check #3 de la plataforma probó subir un objeto especificando una KMS key *distinta* y confirmó que estaba bloqueado:
```
An error occurred (AccessDenied) when calling the PutObject operation:
... not authorized to perform: s3:PutObject on resource "...validation.txt"
with an explicit deny in a resource-based policy
```
Esto confirma que el bucket 2 ya traía preconfigurada (por el sandbox, antes de que tocáramos nada) una bucket policy con `Deny` que impide cifrar con cualquier key que no sea la indicada — exactamente lo que describía el enunciado ("encrypting objects... with other keys is prohibited"). No fue algo que nosotros configuramos ni necesitábamos configurar; ya venía como parte del entorno de la tarea.
