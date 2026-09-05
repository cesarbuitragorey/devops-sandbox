# Teoría — Amazon DynamoDB Data Manipulation, Indexing, and Backup Solutions

## Mover/renombrar un item cuando el "nombre" no es la partition key

En DynamoDB, la partition key de un item es inmutable — no existe un "rename" directo sobre ella. Pero en este lab el valor "humano" del item (`...-ChangeMe`, `...-MigrateMe`) vivía en un atributo normal (`Name`), no en la key (`id`). Por eso:
- **"Actualizar" el item** fue un simple `update-item` sobre el atributo `Name`, sin tocar la key.
- **"Mover" el item** entre tablas requirió el patrón estándar de DynamoDB para migrar entre tablas: `get`/`scan` en origen → `put-item` con los mismos atributos en destino → `delete-item` en origen. No existe una operación nativa "move" entre tablas.

## Global Secondary Index (GSI)

Un GSI permite consultar una tabla por un atributo que **no** es la partition key original (aquí, `PostedBy`), sin tener que hacer un `scan` completo. Para crearlo sobre una tabla existente se usa `update-table` con `--global-secondary-index-updates`, indicando el nuevo atributo primero en `--attribute-definitions` (DynamoDB exige declarar el tipo de cualquier atributo usado como key de un índice, aunque ya exista como atributo normal en los items). La creación es asíncrona — el índice pasa por `CREATING` mientras hace un backfill de todos los items existentes, y solo tras `ACTIVE` puede consultarse.

## Point-In-Time Recovery (PITR) vs. AWS Backup

Son dos mecanismos de backup distintos y complementarios:
- **PITR** (`update-continuous-backups`) habilita restauración continua a cualquier segundo de los últimos N días (por defecto, 35) — pensado para recuperación ante errores operativos recientes (ej. un delete accidental hace 10 minutos), sin necesidad de una política de backups explícita.
- **AWS Backup** (Vault + Plan + Rule + Selection) gestiona snapshots programados periódicos (aquí, diarios) con retención configurable — pensado para cumplimiento/retención a largo plazo, y es un servicio centralizado que puede aplicar la misma política a múltiples tipos de recurso (DynamoDB, RDS, EBS, etc.), no solo DynamoDB.

## Anatomía de un Backup Plan

Un plan de AWS Backup se compone de 4 piezas independientes que se enlazan entre sí:
1. **Vault** — el contenedor de almacenamiento donde viven los recovery points (cifrado con una clave de KMS).
2. **Plan** — el conjunto de reglas de backup (puede tener varias).
3. **Rule** — una programación específica dentro del plan (`ScheduleExpression` en formato cron, ventanas de inicio/finalización).
4. **Selection (Resource Assignment)** — qué recursos concretos (por ARN, o por tags) se les aplica el plan, y con qué rol de IAM se ejecutan los backups.

## El rol de servicio de AWS Backup no se crea automáticamente por CLI

A diferencia de la consola de AWS (que ofrece crear automáticamente un rol `AWSBackupDefaultServiceRole` la primera vez que se usa el servicio), la CLI no lo genera por defecto — hay que crearlo explícitamente con una política de confianza para `backup.amazonaws.com` y las policies administradas `AWSBackupServiceRolePolicyForBackup`/`...ForRestores`, o el `create-backup-selection` falla más adelante al no encontrar un rol asumible por el servicio.

## Deny explícito sobre `Allow` para restringir una sola acción

La política IAM personalizada de este lab combina un `Allow` amplio (`CreateTable`, `ListTables`, `DeleteTable`) con un `Deny` explícito sobre una acción específica (`DeleteBackup`) — en la evaluación de políticas de IAM, un `Deny` explícito siempre gana sobre cualquier `Allow`, sin importar en qué política o de qué fuente venga. Es el patrón estándar para "permitir todo esto, excepto esto otro" dentro de una sola política, sin depender de boundaries u otras políticas separadas.
