# Teoría — Data Lifecycle Manager (DLM) con scripts pre/post

> **Estado del lab: ⏳ Pendiente de pasar los checks de la plataforma.** La configuración descrita aquí está verificada como correcta a nivel de API de AWS (ver `03-resultados`), pero el check automatizado #1 de la plataforma no la reconoce. Ver el detalle del bloqueo en `03-resultados`.

## AWS Data Lifecycle Manager (DLM)

DLM automatiza la creación, retención y eliminación de snapshots de EBS (y AMIs) según una política declarativa — sin necesidad de un cron job propio para backups. Una política de DLM define:
- **A qué recursos aplica** (`TargetTags` — instancias o volúmenes que tengan cierto tag).
- **Con qué frecuencia** crear snapshots (`CreateRule`: intervalo + hora de inicio).
- **Cuánto conservar** antes de borrar automáticamente (`RetainRule`: por cantidad o por días).

## Políticas "instance-based" (multi-volume) vs. "volume-based"

Cuando `ResourceTypes: ["INSTANCE"]` (en vez de `["VOLUME"]`), DLM crea un snapshot **de todos los volúmenes EBS adjuntos a la instancia en el mismo instante** (snapshot "crash-consistent" a nivel de instancia) — necesario para bases de datos con múltiples discos, donde snapshotear cada volumen por separado y en momentos distintos podría dejar los datos inconsistentes entre sí.

## El problema de la consistencia de datos en caliente

Un snapshot de un volumen EBS mientras la base de datos sigue escribiendo activamente puede capturar un estado a medio escribir (ej. una transacción incompleta) — "crash-consistent" pero no necesariamente "application-consistent". La solución estándar: **detener el servicio de base de datos justo antes del snapshot** (para que no haya escrituras en vuelo) y **reiniciarlo justo después** — de ahí los scripts "pre" y "post" de este lab.

## Scripts Pre/Post en DLM — lo que la documentación no deja tan claro

A través de prueba y error con la API real (`--generate-cli-skeleton` y los mensajes de error de validación), se confirmaron varios detalles que no son evidentes solo leyendo la documentación conceptual:

1. El campo `Scripts` vive dentro de **`Schedules[].CreateRule.Scripts`** — no directamente en `Schedules[]` (el primer intento con `Scripts` como hermano de `CreateRule` fue rechazado por el CLI: `Unknown parameter in PolicyDetails.Schedules[0]: "Scripts"`).
2. **Solo se permite un script por schedule** (`LimitExceededException: You've reached the limit on the number of scripts... up to {1} script(s) per schedule`) — para cubrir tanto PRE como POST hay que usar **una sola entrada** con `"Stages": ["PRE", "POST"]`, no dos entradas separadas.
3. El campo `Scripts` **no tiene ningún parámetro para pasarle un valor al documento SSM invocado** (no existe un campo `Parameters` en el schema de `Scripts`, confirmado con `--generate-cli-skeleton`). Esto significa que DLM invoca el mismo documento tanto en PRE como en POST, sin decirle explícitamente cuál es cuál — el documento debe **decidir por sí mismo** qué hacer, típicamente revisando el estado actual del servicio (si está corriendo, deteberlo; si está detenido, arrancarlo) — exactamente como pide el enunciado: "which stops or starts mysql service **based on the current status of the mysql**".
4. El parámetro del documento SSM invocado por DLM debe llamarse literalmente **`command`** — un requisito no documentado que solo salió a la luz vía el mensaje de error real de la API: `"The specified SSM document must provide allowed values in {parameters.command.allowedValues}"`. Usar cualquier otro nombre de parámetro (se probó con `action`) hace que la creación de la política falle con `InvalidRequestException`.

## Por qué "depurar leyendo los mensajes de error reales" fue más confiable que la documentación

Varias de las reglas anteriores (un solo script por schedule, el nombre exacto `command`, la ubicación anidada de `Scripts`) no están escritas de forma clara en ningún lugar fácil de encontrar en la documentación pública de DLM — se descubrieron iterando directamente contra la API real y leyendo con cuidado cada mensaje de error de validación, que en este caso fueron sorprendentemente específicos y útiles (a diferencia del `MalformedXML` genérico visto en otros labs de S3).
