# Práctica — IAM Inline and Managed Policies

## Enunciado de la tarea

> Use customer-managed policies and inline policies.

**Región:** `eu-west-1`

**Recursos de la tarea** (ya provisionados por el sandbox):
- IAM User: `cmtr-iacp1ebx-iam-iamp-user`
- Customer Managed Policy: `cmtr-iacp1ebx-iam-iamp-iam_policy-managed` (ya existía, vacía/skeleton)
- IAM Roles: `cmtr-iacp1ebx-iam-iamp-iam_role-managed`, `cmtr-iacp1ebx-iam-iamp-iam_role-inline`

**Objetivos (4 movimientos):**
1. Configurar la política managed con: `AssumeRole`, listar todos los buckets S3, listar contenido de un bucket, listar todos los roles, listar todos los usuarios.
2. Adjuntar la política managed al usuario.
3. Adjuntar la misma política managed al rol "managed".
4. Crear una política inline en el rol "inline" con solo los dos permisos de S3.

**Entorno real usado:** sandbox AWS, cuenta `557690618589`. Trabajé por **CLI**.

---

## Movimiento 1 — Configurar la política managed

```bash
cat > managed-policy.json << EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "sts:AssumeRole",
        "s3:ListAllMyBuckets",
        "s3:ListBucket",
        "iam:ListRoles",
        "iam:ListUsers"
      ],
      "Resource": "*"
    }
  ]
}
EOF

POLICY_ARN=$(aws iam create-policy \
  --policy-name cmtr-iacp1ebx-iam-iamp-iam_policy-managed \
  --policy-document file://managed-policy.json \
  --region eu-west-1 \
  --query 'Policy.Arn' --output text)
```

### Incidente: la política ya existía — `EntityAlreadyExists`

```
An error occurred (EntityAlreadyExists) when calling the CreatePolicy operation:
A policy called cmtr-iacp1ebx-iam-iamp-iam_policy-managed already exists.
```

El sandbox pre-crea la política (probablemente vacía, como placeholder) — "Configure the managed policy" en el enunciado significa **actualizarla con una nueva versión**, no crearla desde cero. Fix:

```bash
POLICY_ARN=$(aws iam list-policies \
  --scope Local \
  --query "Policies[?PolicyName=='cmtr-iacp1ebx-iam-iamp-iam_policy-managed'].Arn" \
  --output text)

aws iam create-policy-version \
  --policy-arn $POLICY_ARN \
  --policy-document file://managed-policy.json \
  --set-as-default
```
```json
{"PolicyVersion": {"VersionId": "v3", "IsDefaultVersion": true, "CreateDate": "2026-08-25T23:33:11+00:00"}}
```
El `--set-as-default` es obligatorio — sin él la versión queda creada pero inactiva.

## Movimiento 2 — Adjuntar la política al usuario

```bash
aws iam attach-user-policy \
  --user-name cmtr-iacp1ebx-iam-iamp-user \
  --policy-arn $POLICY_ARN
```

## Movimiento 3 — Adjuntar la misma política al rol "managed"

```bash
aws iam attach-role-policy \
  --role-name cmtr-iacp1ebx-iam-iamp-iam_role-managed \
  --policy-arn $POLICY_ARN
```

## Movimiento 4 — Política inline en el rol "inline"

Solo con los dos permisos de S3 (sin `AssumeRole` ni acciones de IAM):

```bash
cat > inline-policy.json << EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:ListAllMyBuckets",
        "s3:ListBucket"
      ],
      "Resource": "*"
    }
  ]
}
EOF

aws iam put-role-policy \
  --role-name cmtr-iacp1ebx-iam-iamp-iam_role-inline \
  --policy-name s3-list-inline-policy \
  --policy-document file://inline-policy.json
```

## Verificación

```bash
aws iam list-attached-user-policies --user-name cmtr-iacp1ebx-iam-iamp-user
aws iam list-attached-role-policies --role-name cmtr-iacp1ebx-iam-iamp-iam_role-managed
aws iam list-role-policies --role-name cmtr-iacp1ebx-iam-iamp-iam_role-inline
```
```json
{"AttachedPolicies": [{"PolicyName": "cmtr-iacp1ebx-iam-iamp-iam_policy-managed", "PolicyArn": "arn:aws:iam::557690618589:policy/cmtr-iacp1ebx-iam-iamp-iam_policy-managed"}]}
```
(mismo resultado para el rol managed)
```json
{"PolicyNames": ["s3-list-inline-policy"]}
```

**Lección**: cuando el enunciado dice "Configure the [recurso]" en vez de "Create the [recurso]", vale la pena verificar primero si ya existe (`list-policies`, `get-role`, etc.) antes de asumir que hay que crearlo desde cero — varios labs de este módulo pre-provisionan recursos "vacíos" que solo necesitan ser completados/actualizados.
