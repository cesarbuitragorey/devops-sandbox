# Práctica — Using AWS Managed Policies for IAM Resources

## Enunciado de la tarea

> Configure two IAM roles by attaching AWS managed policies.

**Región:** `eu-west-1`

**Recursos de la tarea** (ya provisionados por el sandbox):
- Read-Only Role: `${...}` → en mi ejecución: `cmtr-iacp1ebx-iam-mp-iam_role-readonly`
- Administrator Role: `${...}` → en mi ejecución: `cmtr-iacp1ebx-iam-mp-iam_role-administrator`

**Objetivo (2 movimientos):** otorgar a cada rol la política administrada por AWS que corresponde a su nombre/función — no crear políticas propias.

**Entorno real usado:** sandbox AWS con credenciales STS temporales, cuenta `061051254561`. Trabajé por **CLI** (CloudShell).

---

## Movimiento 1 — Rol de solo lectura

```bash
aws iam attach-role-policy \
  --role-name cmtr-iacp1ebx-iam-mp-iam_role-readonly \
  --policy-arn arn:aws:iam::aws:policy/ReadOnlyAccess \
  --region eu-west-1
```

## Movimiento 2 — Rol administrador

```bash
aws iam attach-role-policy \
  --role-name cmtr-iacp1ebx-iam-mp-iam_role-administrator \
  --policy-arn arn:aws:iam::aws:policy/AdministratorAccess \
  --region eu-west-1
```

## Verificación

```bash
aws iam list-attached-role-policies --role-name cmtr-iacp1ebx-iam-mp-iam_role-readonly
aws iam list-attached-role-policies --role-name cmtr-iacp1ebx-iam-mp-iam_role-administrator
```

```json
{"AttachedPolicies": [{"PolicyName": "ReadOnlyAccess", "PolicyArn": "arn:aws:iam::aws:policy/ReadOnlyAccess"}]}
```
```json
{"AttachedPolicies": [{"PolicyName": "AdministratorAccess", "PolicyArn": "arn:aws:iam::aws:policy/AdministratorAccess"}]}
```

Lab directo, sin incidentes — el más corto del módulo hasta ahora.
