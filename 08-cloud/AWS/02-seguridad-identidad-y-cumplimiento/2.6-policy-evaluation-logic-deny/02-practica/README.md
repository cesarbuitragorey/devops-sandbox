# Práctica — Policy Evaluation Logic (Deny)

## Enunciado de la tarea

> Explore the process of evaluating policies and configure both identity-based policy and resource-based policy for a specific role.

**Región:** `eu-west-1`

**Recursos de la tarea** (ya provisionados por el sandbox):
- IAM Role: `cmtr-iacp1ebx-iam-peld-iam_role`
- S3 Bucket: `cmtr-iacp1ebx-iam-peld-bucket-7484718` — **ya con una política existente** (importante: no reemplazarla, hay que ampliarla)

**Objetivos (2 movimientos):**
1. Dar acceso completo a S3 al rol, usando una política administrada por AWS existente (no crear una propia) → **identity-based policy**.
2. Actualizar la política del bucket para prohibir el borrado de objetos específicamente para ese rol → **resource-based policy**.

**Entorno real usado:** sandbox AWS, cuenta `160885290237`. Trabajé por **CLI**.

---

## Movimiento 1 — Acceso completo a S3 (identity-based policy)

```bash
aws iam attach-role-policy \
  --role-name cmtr-iacp1ebx-iam-peld-iam_role \
  --policy-arn arn:aws:iam::aws:policy/AmazonS3FullAccess \
  --region eu-west-1
```

## Movimiento 2 — Ampliar la política del bucket (resource-based policy)

### Paso 1: obtener la política actual del bucket (no reemplazar, ampliar)

```bash
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

aws s3api get-bucket-policy \
  --bucket cmtr-iacp1ebx-iam-peld-bucket-7484718 \
  --query Policy --output text > current-bucket-policy.json

cat current-bucket-policy.json
```

Resultado — la política ya traía un `Allow` de `s3:DeleteObject` para ese mismo rol (dato clave para lo que sigue):
```json
{"Version":"2012-10-17","Statement":[{"Sid":"PublicReadGetObject","Effect":"Allow","Principal":{"AWS":"arn:aws:iam::160885290237:role/cmtr-iacp1ebx-iam-peld-iam_role"},"Action":"s3:DeleteObject","Resource":"arn:aws:s3:::cmtr-iacp1ebx-iam-peld-bucket-7484718/*"}]}
```

### Paso 2: agregar un statement `Deny` (sin tocar el existente) y aplicar

```bash
NEW_STATEMENT=$(cat << EOF
{
  "Sid": "DenyDeleteForPeldRole",
  "Effect": "Deny",
  "Principal": {
    "AWS": "arn:aws:iam::${ACCOUNT_ID}:role/cmtr-iacp1ebx-iam-peld-iam_role"
  },
  "Action": ["s3:DeleteObject", "s3:DeleteObjectVersion"],
  "Resource": "arn:aws:s3:::cmtr-iacp1ebx-iam-peld-bucket-7484718/*"
}
EOF
)

jq --argjson stmt "$NEW_STATEMENT" '.Statement += [$stmt]' current-bucket-policy.json > new-bucket-policy.json

aws s3api put-bucket-policy \
  --bucket cmtr-iacp1ebx-iam-peld-bucket-7484718 \
  --policy file://new-bucket-policy.json
```

## El punto central del lab: `Allow` + `Deny` conviviendo

Tras el Movimiento 2, la política del bucket queda con **ambos** statements para el mismo rol y la misma acción:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {"Sid": "PublicReadGetObject", "Effect": "Allow", "Principal": {"AWS": ".../cmtr-iacp1ebx-iam-peld-iam_role"}, "Action": "s3:DeleteObject", "Resource": ".../*"},
    {"Sid": "DenyDeleteForPeldRole", "Effect": "Deny", "Principal": {"AWS": ".../cmtr-iacp1ebx-iam-peld-iam_role"}, "Action": ["s3:DeleteObject", "s3:DeleteObjectVersion"], "Resource": ".../*"}
  ]
}
```

Esto **no es un error ni un conflicto que haya que "resolver" borrando el Allow** — es exactamente la demostración de la lógica de evaluación de IAM: el `Deny` explícito gana sobre el `Allow` explícito sin importar que convivan en la misma política. No hace falta (ni conviene) tocar el statement original.

## Verificación real

```bash
# Debe fallar con AccessDenied
aws s3api delete-object --bucket cmtr-iacp1ebx-iam-peld-bucket-7484718 --key object.html
```
```
An error occurred (AccessDenied) when calling the DeleteObject operation:
... is not authorized to perform: s3:DeleteObject on resource "arn:aws:s3:::cmtr-iacp1ebx-iam-peld-bucket-7484718/object.html"
with an explicit deny in a resource-based policy
```

El mensaje de error confirma explícitamente `"with an explicit deny in a resource-based policy"` — evidencia directa de que fue el `Deny` de la bucket policy el que bloqueó la acción (y no, por ejemplo, la ausencia de un `Allow`).
