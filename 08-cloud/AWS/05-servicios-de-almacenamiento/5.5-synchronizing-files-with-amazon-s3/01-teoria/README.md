# Teoría — Sincronización, versionado y replicación cross-region en S3

## `aws s3 sync` vs. `aws s3 cp`

`aws s3 sync <origen> <destino>` compara el contenido de origen y destino, y solo transfiere los archivos **nuevos o modificados** (por tamaño y fecha de modificación) — a diferencia de `cp`, que copia siempre, sin comparar. Es la herramienta natural para una tarea recurrente de backup incremental como la de este lab: correr `sync` cada minuto vía cron solo mueve lo que cambió desde la última corrida, no repite trabajo innecesario.

## `NoncurrentVersionExpiration.NewerNoncurrentVersions`

Para "retener solo las últimas N versiones" de un objeto (y borrar el resto), la clave de la regla de lifecycle es `NewerNoncurrentVersions` dentro de `NoncurrentVersionExpiration` — indica cuántas versiones no vigentes más recientes conservar; cualquier versión no vigente más allá de esa cantidad se elimina.

**Detalle importante descubierto en este lab**: `NewerNoncurrentVersions` no puede usarse solo — S3 exige que la regla también incluya `NoncurrentDays` (aunque sea `1`). Sin `NoncurrentDays`, la API rechaza la configuración con `MalformedXML`, un error poco descriptivo del problema real (no es un tema de sintaxis JSON/XML, sino de un campo obligatorio faltante en la combinación de parámetros).

## Cross-Region Replication (CRR)

CRR copia automáticamente los objetos de un bucket "origen" a un bucket "destino" en **otra región** (a diferencia de Same-Region Replication, que replica dentro de la misma región). Requisitos:
- **Versionado habilitado en ambos buckets** — la replicación depende del mecanismo de versiones de S3.
- Un **rol de IAM** con permisos para leer del bucket origen y escribir en el destino — en este lab, ese rol (`s3crr_role_for_...`) ya venía pre-creado por el sandbox, solo hacía falta referenciarlo en la configuración de replicación (`put-bucket-replication`), no crearlo desde cero.
- La replicación aplica solo a objetos subidos **después** de configurarla — no replica retroactivamente lo que ya existía en el bucket origen.

## Cron jobs por usuario específico en Linux

`crontab -u <usuario>` gestiona el crontab de un usuario distinto al que ejecuta el comando (requiere privilegios root/sudo para editar el de otro usuario). Es importante correr el sync como el usuario correcto (`ec2-user` en este lab, no `root`), porque las credenciales de AWS CLI, el `PATH`, y los permisos de archivo dentro de `/backups` están atados a ese usuario específico.

## Por qué "redirigir la salida al log exacto" es parte de la validación

El enunciado insiste en que la salida del cron job debe ir a `/home/ec2-user/sync_s3.log` específicamente (con `>> archivo 2>&1` para capturar tanto salida estándar como errores) — esto es lo que la plataforma usa como evidencia de que el cron corrió y qué hizo, sin necesidad de inspeccionar el bucket directamente. Si el output se hubiera perdido (sin redirección) o hubiera ido a otro archivo, la tarea no se habría podido validar aunque la sincronización funcionara igual de bien.
