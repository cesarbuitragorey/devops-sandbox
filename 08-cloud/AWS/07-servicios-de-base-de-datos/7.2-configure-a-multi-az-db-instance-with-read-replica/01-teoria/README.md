# Teoría — Configure a Multi-AZ DB Instance with Read-Replica

## Multi-AZ vs. Read Replica: dos mecanismos distintos, no intercambiables

**Multi-AZ** crea una instancia standby en otra AZ con **replicación síncrona**, pensada exclusivamente para **alta disponibilidad**: el standby no es accesible para lecturas, solo existe para asumir el rol de primario automáticamente ante un fallo o un "reboot with failover" manual. **Read Replica** usa **replicación asíncrona** y sí es accesible (para lecturas), pensada para **escalar el rendimiento de lectura** distribuyendo el tráfico de consultas fuera del primario. Este lab combina ambos: Multi-AZ para disponibilidad del primario, y un read-replica adicional para descargar lecturas — son features complementarias, no alternativas.

## `reboot-db-instance --force-failover`

Este comando fuerza que la instancia standby (creada por Multi-AZ) se convierta en el nuevo primario, y el antiguo primario pase a standby — simula el comportamiento de un failover real sin esperar a que ocurra una falla espontánea. Es una operación disruptiva de corta duración (segundos): las conexiones activas se cortan y deben reconectar, razón por la cual el enunciado advierte que "errores temporales en los logs durante el failover son esperados".

## Por qué el `DbiResourceId` es más confiable que el `DBInstanceIdentifier` visible en el enunciado

El enunciado de la tarea listaba la instancia como `db-6TE3SW4BYSKZYXS34ELID5VJYE` — resultó ser el **`DbiResourceId`** (un identificador interno inmutable de AWS), no el `DBInstanceIdentifier` real (`cmtr-iacp1ebx-rds-madi-rds-2770760-primary`), que es el nombre que efectivamente acepta la CLI en `--db-instance-identifier`. Cuando un identificador de una tarea no es reconocido por la API, vale la pena listar los recursos existentes (`describe-db-instances` sin filtro) en vez de asumir un error de tipeo.

## Verificación de un failover real vía `describe-events`

El campo `AvailabilityZone` de `describe-db-instances` no siempre refleja de inmediato (o de forma obvia) el swap primario↔standby tras un failover. La evidencia más confiable es el historial de eventos de la instancia (`aws rds describe-events`), que registra explícitamente `Multi-AZ instance failover started` y `Multi-AZ instance failover completed` — esto es lo que efectivamente usó el checker de la plataforma (vía un evento de CloudTrail `RebootDBInstance` con `forceFailover: true`) para confirmar que el estudiante disparó el failover.

## Permisos del rol de instancia EC2 vs. permisos del usuario/rol que administra RDS

El rol IAM de la instancia EC2 (para SSM) no incluye permisos de `rds:RebootDBInstance` ni `rds:DescribeDBInstances` — intentar administrar RDS **desde dentro de la instancia** (con las credenciales de su instance profile) falla con `AccessDenied`, aunque esas mismas acciones sí funcionan con las credenciales de sandbox del usuario, corridas desde su propia terminal. Es un recordatorio de que el rol de una instancia debe tener solo los permisos que sus aplicaciones necesitan (aquí, SSM), no permisos de administración de infraestructura.
