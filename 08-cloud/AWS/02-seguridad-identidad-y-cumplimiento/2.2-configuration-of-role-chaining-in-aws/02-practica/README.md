# Práctica — Configuration of Role Chaining in AWS

## Enunciado de la tarea

> Configure role chaining using two roles, allowing one dedicated role to assume another role with read-only access.

**Región:** `eu-west-1`

**Recursos de la tarea** (ya provisionados por el sandbox):
- Assume Role `${assume_role}` → en mi ejecución: `cmtr-iacp1ebx-iam-ar-iam_role-assume`
- Read-Only Role `${readonly_role}` → en mi ejecución: `cmtr-iacp1ebx-iam-ar-iam_role-readonly`

**Objetivos (3 movimientos):**
1. Configurar permisos en `assume_role` para que pueda asumir `readonly_role` — sin dar acceso de administrador completo.
2. Dar acceso de solo lectura completo a `readonly_role`, usando una política administrada por AWS existente (no crear una propia).
3. Configurar el trust policy de `readonly_role` para que solo pueda ser asumido por `assume_role`.

**Entorno real usado:** sandbox AWS con credenciales STS temporales, cuenta `396913711198`. Trabajé por **CLI** (CloudShell).

---

## 0. Obtener el Account ID

```bash
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
echo $ACCOUNT_ID
# 396913711198
```

## Movimiento 1 — Permitir que `assume_role` asuma `readonly_role`

No existe una política administrada por AWS para "asumir este ARN específico" (son cuenta-específicas), así que corresponde una política propia — el enunciado solo prohíbe crear política propia en el movimiento 2, no en este. La adjunto como **inline policy** al rol assume, acotada al ARN exacto del rol readonly (no `Resource: "*"`, para no dar acceso a asumir *cualquier* rol):

```bash
cat > assume-readonly-policy.json << EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "sts:AssumeRole",
      "Resource": "arn:aws:iam::${ACCOUNT_ID}:role/cmtr-iacp1ebx-iam-ar-iam_role-readonly"
    }
  ]
}
EOF

aws iam put-role-policy \
  --role-name cmtr-iacp1ebx-iam-ar-iam_role-assume \
  --policy-name allow-assume-readonly-role \
  --policy-document file://assume-readonly-policy.json \
  --region eu-west-1
```

## Movimiento 2 — Acceso de solo lectura completo en `readonly_role`

```bash
aws iam attach-role-policy \
  --role-name cmtr-iacp1ebx-iam-ar-iam_role-readonly \
  --policy-arn arn:aws:iam::aws:policy/ReadOnlyAccess \
  --region eu-west-1
```

## Movimiento 3 — Trust policy de `readonly_role`

Este es el que determina **quién puede asumir** el rol (a diferencia del movimiento 1, que determina qué puede asumir `assume_role`):

```bash
cat > trust-policy-readonly.json << EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::${ACCOUNT_ID}:role/cmtr-iacp1ebx-iam-ar-iam_role-assume"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

aws iam update-assume-role-policy \
  --role-name cmtr-iacp1ebx-iam-ar-iam_role-readonly \
  --policy-document file://trust-policy-readonly.json \
  --region eu-west-1
```

## Verificación por CLI

```bash
export AWS_PAGER=""
aws iam get-role-policy --role-name cmtr-iacp1ebx-iam-ar-iam_role-assume --policy-name allow-assume-readonly-role
aws iam list-attached-role-policies --role-name cmtr-iacp1ebx-iam-ar-iam_role-readonly
aws iam get-role --role-name cmtr-iacp1ebx-iam-ar-iam_role-readonly --query 'Role.AssumeRolePolicyDocument'
```

```json
{"AttachedPolicies": [{"PolicyName": "ReadOnlyAccess", "PolicyArn": "arn:aws:iam::aws:policy/ReadOnlyAccess"}]}
```
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {"AWS": "arn:aws:iam::396913711198:role/cmtr-iacp1ebx-iam-ar-iam_role-assume"},
            "Action": "sts:AssumeRole"
        }
    ]
}
```

## Verificación con AWS Policy Simulator (`https://policysim.aws.amazon.com/`)

1. Rol `cmtr-iacp1ebx-iam-ar-iam_role-assume` → acción `STS:AssumeRole`.

   **Incidente**: al correr la simulación con el recurso por defecto (`role: *`) dio **Denied** ("Implicitly denied — no matching statement"). No es un error — es la prueba de que la política **no** permite asumir cualquier rol, solo el ARN específico. Cambiando el campo Resource al ARN exacto (`arn:aws:iam::396913711198:role/cmtr-iacp1ebx-iam-ar-iam_role-readonly`) y volviendo a correr la simulación, el resultado pasó a **Allowed**.

   **Otro punto a tener en cuenta**: al probar acciones de S3/EC2 sobre el rol `assume_role` (por error, mientras exploraba el simulador) salieron `denied` — correcto y esperado, porque ese rol no tiene ni debe tener permisos sobre esos servicios; su única función es poder asumir `readonly_role`.

2. Rol `cmtr-iacp1ebx-iam-ar-iam_role-readonly` → acción de lectura (ej. `S3:ListBucket`, `EC2:DescribeInstances`) → **Allowed**. Acción de escritura (ej. `S3:PutObject`, `EC2:RunInstances`) → **Denied**.

## Verificación manual — role chaining real (opcional, alternativa al simulador)

```bash
# Paso 1: asumir assume_role
CREDS_ASSUME=$(aws sts assume-role \
  --role-arn arn:aws:iam::396913711198:role/cmtr-iacp1ebx-iam-ar-iam_role-assume \
  --role-session-name test-assume \
  --query 'Credentials' --output json)

export AWS_ACCESS_KEY_ID=$(echo $CREDS_ASSUME | jq -r '.AccessKeyId')
export AWS_SECRET_ACCESS_KEY=$(echo $CREDS_ASSUME | jq -r '.SecretAccessKey')
export AWS_SESSION_TOKEN=$(echo $CREDS_ASSUME | jq -r '.SessionToken')
aws sts get-caller-identity   # confirma assumed-role/.../assume_role

# Paso 2: con esas credenciales, encadenar y asumir readonly_role
CREDS_READONLY=$(aws sts assume-role \
  --role-arn arn:aws:iam::396913711198:role/cmtr-iacp1ebx-iam-ar-iam_role-readonly \
  --role-session-name test-readonly \
  --query 'Credentials' --output json)

export AWS_ACCESS_KEY_ID=$(echo $CREDS_READONLY | jq -r '.AccessKeyId')
export AWS_SECRET_ACCESS_KEY=$(echo $CREDS_READONLY | jq -r '.SecretAccessKey')
export AWS_SESSION_TOKEN=$(echo $CREDS_READONLY | jq -r '.SessionToken')
aws sts get-caller-identity   # confirma assumed-role/.../readonly_role

# Paso 3: probar lectura (debe funcionar) y escritura (debe fallar)
aws s3 ls
aws s3api create-bucket --bucket prueba-readonly-denegado-123456 --region eu-west-1  # AccessDenied esperado
```

> Importante: al terminar, recargar las credenciales originales del sandbox para no seguir operando como `readonly_role` en el resto de la sesión.
