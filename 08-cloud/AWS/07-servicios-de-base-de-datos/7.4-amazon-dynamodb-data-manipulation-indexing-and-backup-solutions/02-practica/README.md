# Práctica — Amazon DynamoDB Data Manipulation, Indexing, and Backup Solutions

## Enunciado de la tarea

> Create a second DynamoDB table with the same structure, migrate/update items between tables, add a GSI, enable PITR, and configure a nightly AWS Backup plan plus a custom IAM policy restricting backup deletion.

**Región:** `eu-west-1` — Cuenta `445567074266`

**Recursos pre-creados:** tabla `cmtr-iacp1ebx-dynamodb-b-table-1` (partition key `id` String, sin sort key) con 2 items: `id=1001` (`Name: ...-ChangeMe`, `PostedBy: User A`) y `id=1002` (`Name: ...-MigrateMe`, `PostedBy: User C`).

**Entorno real usado:** CLI vía CloudShell (disponible en este sandbox).

---

## Movimiento 1 — Inspeccionar la tabla existente

```bash
aws dynamodb describe-table --table-name cmtr-iacp1ebx-dynamodb-b-table-1 \
  --query 'Table.{KeySchema:KeySchema,AttributeDefinitions:AttributeDefinitions,BillingMode:BillingModeSummary.BillingMode}'
aws dynamodb scan --table-name cmtr-iacp1ebx-dynamodb-b-table-1
```
Reveló que el "nombre" del item (`ChangeMe`/`MigrateMe`) vive en el atributo `Name`, no en la partition key (`id`, valores `1001`/`1002`) — simplifica mucho los pasos de "actualizar" y "mover".

## Movimiento 2 — Crear tabla 2 (misma estructura)

```bash
aws dynamodb create-table \
  --table-name cmtr-iacp1ebx-dynamodb-b-table-2 \
  --attribute-definitions AttributeName=id,AttributeType=S \
  --key-schema AttributeName=id,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST
```

### Incidente: pager de `less` traga los comandos siguientes

Igual que en el lab 7.3, la salida del `create-table` quedó abierta en `less`. **Fix**: `aws configure set cli_pager ""`.

## Movimiento 3 — Actualizar item "ChangeMe"

```bash
aws dynamodb update-item \
  --table-name cmtr-iacp1ebx-dynamodb-b-table-1 \
  --key '{"id": {"S": "1001"}}' \
  --update-expression "SET #n = :val" \
  --expression-attribute-names '{"#n": "Name"}' \
  --expression-attribute-values '{":val": {"S": "cmtr-iacp1ebx-dynamodb-b-table-item-Changed"}}'
```

## Movimiento 4 — Migrar item "MigrateMe" de tabla 1 a tabla 2

```bash
cat > migrate-item.json << 'EOF'
{
  "id": {"S": "1002"},
  "PostedBy": {"S": "User C"},
  "Name": {"S": "cmtr-iacp1ebx-dynamodb-b-table-item-MigrateMe"}
}
EOF

aws dynamodb put-item --table-name cmtr-iacp1ebx-dynamodb-b-table-2 --item file://migrate-item.json
aws dynamodb delete-item --table-name cmtr-iacp1ebx-dynamodb-b-table-1 --key '{"id": {"S": "1002"}}'
```
No existe una operación nativa "move" entre tablas — es siempre `put` en destino + `delete` en origen.

## Movimiento 5 — Global Secondary Index en tabla 2

```bash
aws dynamodb update-table \
  --table-name cmtr-iacp1ebx-dynamodb-b-table-2 \
  --attribute-definitions AttributeName=PostedBy,AttributeType=S \
  --global-secondary-index-updates '[{"Create":{"IndexName":"PostedBy-index","KeySchema":[{"AttributeName":"PostedBy","KeyType":"HASH"}],"Projection":{"ProjectionType":"ALL"}}}]'
```
Tardó unos minutos en pasar de `CREATING` a `ACTIVE` (verificado con `describe-table --query 'Table.GlobalSecondaryIndexes[0].IndexStatus'`).

## Movimiento 6 — Point-in-time recovery en tabla 1

```bash
aws dynamodb update-continuous-backups \
  --table-name cmtr-iacp1ebx-dynamodb-b-table-1 \
  --point-in-time-recovery-specification PointInTimeRecoveryEnabled=true
```

## Movimiento 7 — Rol de servicio para AWS Backup

No existía un rol default de AWS Backup en la cuenta (`AWSBackupDefaultServiceRole` → `NoSuchEntity`). Se creó uno propio:
```bash
cat > backup-trust-policy.json << 'EOF'
{
  "Version": "2012-10-17",
  "Statement": [
    {"Effect": "Allow", "Principal": {"Service": "backup.amazonaws.com"}, "Action": "sts:AssumeRole"}
  ]
}
EOF

aws iam create-role --role-name cmtr-iacp1ebx-dynamodb-b-BackupRole --assume-role-policy-document file://backup-trust-policy.json
aws iam attach-role-policy --role-name cmtr-iacp1ebx-dynamodb-b-BackupRole --policy-arn arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup
aws iam attach-role-policy --role-name cmtr-iacp1ebx-dynamodb-b-BackupRole --policy-arn arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForRestores
```

## Movimiento 8 — Vault, Plan y Selection de AWS Backup

```bash
aws backup create-backup-vault --backup-vault-name cmtr-iacp1ebx-dynamodb-b-BackupVault

TABLE2_ARN=$(aws dynamodb describe-table --table-name cmtr-iacp1ebx-dynamodb-b-table-2 --query 'Table.TableArn' --output text)

cat > backup-plan.json << 'EOF'
{
  "BackupPlanName": "cmtr-iacp1ebx-dynamodb-b-BackupPlan",
  "Rules": [
    {
      "RuleName": "cmtr-iacp1ebx-dynamodb-b-DailyBackup",
      "TargetBackupVaultName": "cmtr-iacp1ebx-dynamodb-b-BackupVault",
      "ScheduleExpression": "cron(0 5 * * ? *)",
      "StartWindowMinutes": 60,
      "CompletionWindowMinutes": 120
    }
  ]
}
EOF
aws backup create-backup-plan --backup-plan file://backup-plan.json
# BackupPlanId: 94c0df19-5c14-4025-9402-8c1f73aea8bc

cat > backup-selection.json << EOF
{
  "SelectionName": "DynamoDBTableSelection",
  "IamRoleArn": "arn:aws:iam::445567074266:role/cmtr-iacp1ebx-dynamodb-b-BackupRole",
  "Resources": ["$TABLE2_ARN"]
}
EOF
aws backup create-backup-selection --backup-plan-id 94c0df19-5c14-4025-9402-8c1f73aea8bc --backup-selection file://backup-selection.json
```

## Movimiento 9 — Política IAM personalizada

```bash
cat > restrict-deletion-policy.json << 'EOF'
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["dynamodb:CreateTable", "dynamodb:ListTables", "dynamodb:DeleteTable"],
      "Resource": "*"
    },
    {
      "Effect": "Deny",
      "Action": "dynamodb:DeleteBackup",
      "Resource": "*"
    }
  ]
}
EOF

aws iam create-policy \
  --policy-name cmtr-iacp1ebx-dynamodb-b-iam_policy-RestrictDeletion \
  --policy-document file://restrict-deletion-policy.json
```

## Verificación

```bash
aws dynamodb scan --table-name cmtr-iacp1ebx-dynamodb-b-table-1 --query 'Items[].Name.S'
aws dynamodb scan --table-name cmtr-iacp1ebx-dynamodb-b-table-2 --query 'Items[].Name.S'
```
Confirmó tabla 1 con solo `...-Changed` y tabla 2 con `...-MigrateMe`.
