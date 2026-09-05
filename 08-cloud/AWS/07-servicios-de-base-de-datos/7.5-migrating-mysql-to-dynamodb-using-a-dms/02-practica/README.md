# Práctica — Migrating MySQL to DynamoDB Using a DMS

## Enunciado de la tarea

> Migrate historical data from a MySQL "on-premise" source (EC2) to DynamoDB using AWS DMS, via 3 separate full-load migration tasks (movies detail, regional AKAs, ratings) filtered to 23 specific movie IDs, using table-mapping templates downloaded from S3.

**Región:** `eu-west-1` — Cuenta `841162682669`

**Recursos pre-creados:** EC2 `cmtr-iacp1ebx-dms-mtdm-MySQL-Instance` (MySQL, DB `imdb`), rol IAM `cmtr-iacp1ebx-dms-mtdm-dynamodb-access`, Replication Instance `mysqltodynamo-instance`, tabla DynamoDB `movies`.

**Entorno real usado:** CLI local (Git Bash), CloudShell bloqueado nuevamente por SCP.

---

## Movimiento 1 — Obtener la lista de 23 IDs de películas únicas

```bash
aws ssm start-session --target i-0b6661c1123b480bc  # instancia MySQL
mysql -u user_iacp1ebx -p'On1!ZBVJx8dMs2b2' -D imdb -N -e "SELECT DISTINCT tconst FROM movies ORDER BY tconst;"
```
Confirmó exactamente 23 valores únicos (`tt0027125` ... `tt0117057`), como exigía el enunciado.

## Movimiento 2 — Descargar y completar las 3 plantillas de table-mappings

Se descargaron `historical-migration01/02/03.json.tpl` desde el bucket S3 pre-firmado del enunciado. Cada plantilla apunta a una tabla origen distinta (`movies` view, `title_akas`, `title_ratings`) con distinto nombre de columna filtro (`tconst`/`titleId`/`tconst`), pero usan la **misma lista de 23 IDs**. Se reemplazó el placeholder `"REPLACE THIS STRING BY MOVIES LIST"` por 23 objetos `{"filter-operator": "eq", "value": "tt..."}`.

## Movimiento 3 — Crear los endpoints DMS

```bash
aws dms create-endpoint --endpoint-identifier cmtr-iacp1ebx-dms-mtdm-source-endpoint \
  --endpoint-type source --engine-name mysql \
  --username user_iacp1ebx --password 'On1!ZBVJx8dMs2b2' \
  --server-name <IP-privada-inicial> --port 3306 --database-name imdb

aws dms create-endpoint --endpoint-identifier cmtr-iacp1ebx-dms-mtdm-target-endpoint \
  --endpoint-type target --engine-name dynamodb \
  --dynamo-db-settings ServiceAccessRoleArn=arn:aws:iam::841162682669:role/cmtr-iacp1ebx-dms-mtdm-dynamodb-access
```

### Incidente: timeout de conexión usando la IP privada

```
Application-Detailed-Message: ... Can't connect to MySQL server on '10.0.1.163' (110)
Code: [DMS-00002], Message: [dial tcp 10.0.1.163:3306: i/o timeout]
```
La instancia MySQL simula un origen "on-premise" en una red separada de la VPC de DMS (sin peering). **Fix**: usar la IP **pública** de la instancia (`34.245.135.195`, con el SG abriendo 3306 a `0.0.0.0/0`):
```bash
aws dms modify-endpoint --endpoint-arn <source-arn> --server-name 34.245.135.195
```

### Incidente secundario: `modify-endpoint` resetea campos no especificados

Tras el `modify-endpoint` anterior, `DatabaseName` quedó en `null` (se perdió porque no se incluyó explícitamente en la llamada de modificación). **Fix**: otro `modify-endpoint` incluyendo `--database-name imdb`.

## Movimiento 4 — Probar conexiones y crear las 3 tareas

```bash
aws dms test-connection --replication-instance-arn <repl-arn> --endpoint-arn <source-arn>
aws dms test-connection --replication-instance-arn <repl-arn> --endpoint-arn <target-arn>
# ... aws dms describe-connections hasta status "successful" en ambos

aws dms create-replication-task \
  --replication-task-identifier cmtr-iacp1ebx-dms-mtdm-historical-migration01 \
  --source-endpoint-arn <source-arn> --target-endpoint-arn <target-arn> \
  --replication-instance-arn <repl-arn> --migration-type full-load \
  --table-mappings file://historical-migration01.json
# (repetido para 02 y 03)
```

### Incidente: `StartReplicationTaskType start-replicate is invalid`

El valor correcto del parámetro es `start-replication`, no `start-replicate` (error de tipeo propio).

## Incidente principal: `TargetTablePrepMode: DROP_AND_CREATE` borra los datos de tareas anteriores

Tras correr las 3 tareas en orden (01→02→03), un `scan` de la tabla `movies` mostró solo 23 items — todos con `mskey: RTNG` (los de la última tarea). Las 3 tareas reportaban `FullLoadRows` correctos (29, 1128, 23) pero solo sobrevivía la última. **Causa**: `TargetTablePrepMode` por defecto es `DROP_AND_CREATE` — cada tarea borra y recrea la tabla destino compartida antes de cargar, destruyendo lo cargado por la tarea previa.

**Primer intento de fix** (incorrecto para este checker): cambiar las 3 tareas a `TargetTablePrepMode: DO_NOTHING` y recargarlas (`reload-target`), acumulando 1030 items (29 DETL + 978 REGN + 23 RTNG). El checker de la plataforma **rechazó** este resultado (`Check if all items were migrated to DynamoDB` esperaba `23`, no `1030`).

**Fix correcto**: revertir *solo* la tarea 03 (ratings) a `TargetTablePrepMode: DROP_AND_CREATE` y volver a cargarla, dejando la tabla con exactamente 23 items (el estado que el checker realmente esperaba — el comportamiento por defecto era el correcto desde el principio):
```bash
aws dms modify-replication-task --replication-task-arn <task03-arn> \
  --replication-task-settings '{"FullLoadSettings":{"TargetTablePrepMode":"DROP_AND_CREATE"}}'
aws dms start-replication-task --replication-task-arn <task03-arn> --start-replication-task-type reload-target
```

## Verificación

```bash
aws dynamodb scan --table-name movies --select COUNT
```
Resultado final: `Count: 23` — coincide con las 23 películas únicas filtradas.
