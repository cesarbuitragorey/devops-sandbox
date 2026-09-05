# Resultados — Amazon DynamoDB Data Manipulation, Indexing, and Backup Solutions

**Estado:** ✅ Tarea completada y verificada por la plataforma (10/10 checks aprobados)

## Resumen de los recursos configurados

| Recurso | Configuración |
|---|---|
| Tabla 2 | `cmtr-iacp1ebx-dynamodb-b-table-2`, misma estructura que tabla 1 (`id` String, `PAY_PER_REQUEST`) |
| Item actualizado | Tabla 1, `id=1001`, `Name: ...-Changed` |
| Item migrado | Tabla 2, `id=1002`, `Name: ...-MigrateMe` (eliminado de tabla 1) |
| GSI | `PostedBy-index` en tabla 2, `ACTIVE` |
| PITR | Habilitado en tabla 1, retención 35 días |
| Backup Vault | `cmtr-iacp1ebx-dynamodb-b-BackupVault` |
| Backup Plan | `cmtr-iacp1ebx-dynamodb-b-BackupPlan`, regla `cmtr-iacp1ebx-dynamodb-b-DailyBackup` (diaria, cron) |
| Backup Selection | `DynamoDBTableSelection`, apunta a tabla 2, rol `cmtr-iacp1ebx-dynamodb-b-BackupRole` |
| Política IAM | `cmtr-iacp1ebx-dynamodb-b-iam_policy-RestrictDeletion` (Allow create/list/delete tabla, Deny `DeleteBackup`) |

## Verificación automática de la plataforma

1. **Tabla 2 existe** ✅
2. **Item actualizado en tabla 1** ✅ (`...-Changed`)
3. **Item migrado presente en tabla 2** ✅ (`...-MigrateMe`)
4. **Item eliminado de tabla 1** ✅ (`Count: 0`)
5. **PITR habilitado en tabla 1** ✅
6. **Backup Vault correcto** ✅
7. **Backup Plan correcto** ✅
8. **Backup Selection correcta** ✅
9. **Política IAM con los permisos/efectos correctos** ✅
10. **GSI `ACTIVE`** ✅

## Recursos

Al finalizar se usó el botón **"Destroy Resources"** de la plataforma.
