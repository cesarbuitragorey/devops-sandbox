# Teoría — Migrating MySQL to DynamoDB Using a DMS

## AWS DMS: endpoints, replication instance y tasks son piezas independientes

Un flujo de migración con DMS separa 3 conceptos:
- **Endpoints** (origen y destino) — solo credenciales/configuración de conexión, no ejecutan nada por sí solos.
- **Replication Instance** — el cómputo (una instancia administrada) que efectivamente mueve los datos.
- **Replication Task** — define QUÉ migrar (via `table-mappings`) y CÓMO (via `replication-task-settings`), vinculando un origen, un destino y una replication instance.

Esto permite reutilizar la misma replication instance y los mismos endpoints en múltiples tasks distintas — como en este lab, donde las 3 tareas de migración comparten los mismos 2 endpoints y la misma replication instance.

## `TargetTablePrepMode`: la trampa de compartir tabla destino entre varias tareas

`FullLoadSettings.TargetTablePrepMode` controla qué hace DMS con la tabla destino **antes** de cargar los datos de una tarea de full-load. El valor por defecto, `DROP_AND_CREATE`, borra y recrea la tabla destino desde cero en cada ejecución. Si varias replication tasks apuntan al **mismo** nombre de tabla destino (como en este lab, las 3 migraciones escriben a la tabla DynamoDB `movies`), cada tarea que se ejecuta después **destruye los datos que dejó la tarea anterior** — el resultado final solo contiene lo cargado por la última tarea ejecutada, no la unión de las 3.

Esto es contraintuitivo si se espera que las 3 tareas coexistan aditivamente (como en un patrón adjacency-list clásico), pero en este lab específico resultó ser el comportamiento *correcto y esperado* por el checker de la plataforma: el estado final validado era el de la tabla tras la última tarea (`ratings`, 23 registros) — no la suma acumulada de las 3.

## Adjacency List Pattern en DynamoDB

El patrón consiste en usar una partition key común (aquí, `mpkey`) para representar una "entidad" (una película), y variar la sort key (`mskey`) para representar distintos tipos de datos relacionados de esa misma entidad como items separados (`DETL|categoria|orden`, `REGN|region`, `RTNG`) bajo el mismo partition key. Es la forma estándar en DynamoDB (una base de datos sin joins) de modelar relaciones uno-a-muchos dentro de una sola tabla. En este lab se usó la infraestructura de este patrón (mapping-parameters con `partition-key-name`/`sort-key-name`), aunque el resultado final validado terminó siendo solo uno de los 3 "tipos" de item (por el `DROP_AND_CREATE` compartido).

## Migrar desde un origen tratado como "on-premise": IP pública, no privada

El diagrama de este lab modela la instancia MySQL como si estuviera "on-premise", en una VPC separada de la VPC donde vive la replication instance de DMS. Aunque ambas están técnicamente en la misma cuenta/región, no comparten red privada — por eso el endpoint de origen debe apuntar a la **IP pública** de la instancia MySQL (con el security group abriendo 3306 a 0.0.0.0/0), no a su IP privada de VPC, ya que no hay peering ni conectividad privada entre ambas redes.

## `full-load` vs. CDC (Change Data Capture)

Al no especificar `--migration-type` con `cdc` en el mix (aquí, `full-load` puro), la tarea copia el snapshot actual de los datos filtrados y se detiene (`stopped`) al terminar — no queda escuchando cambios continuos en el origen. Es el modo apropiado para una migración histórica puntual (como el nombre `historical-migration0N` sugiere), en contraposición a una replicación continua real-time.
