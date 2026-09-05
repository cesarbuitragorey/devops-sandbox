# Resultados — Configure a Multi-AZ DB Instance with Read-Replica

**Estado:** ✅ Tarea completada y verificada por la plataforma (4/4 checks aprobados)

## Resumen de los recursos configurados

| Recurso | Configuración |
|---|---|
| RDS Primario | `cmtr-iacp1ebx-rds-madi-rds-2770760-primary`, `MultiAZ: true`, AZ primaria `eu-west-1a`, AZ secundaria `eu-west-1b` |
| Read Replica | `db-replica`, `db.t3.micro`, `PubliclyAccessible: false`, `MonitoringInterval: 0` |
| `data-collector` | `ENDPOINT="db-replica.clw26o2smg1o.eu-west-1.rds.amazonaws.com"`, reiniciado y verificado leyendo datos reales |
| `data-generator` | Insertando exitosamente cada 60s en `taskdb.addressbook` (base creada manualmente, ver práctica) |
| Failover | Disparado con `reboot-db-instance --force-failover`, confirmado por eventos `Multi-AZ instance failover started/completed` |

## Verificación automática de la plataforma

1. **Multi-AZ habilitado** ✅ (`true`)
2. **Read replica creado** ✅ (`db-replica`)
3. **`data-collector` usando el endpoint del replica** ✅ (`ENDPOINT="db-replica.clw26o2smg1o.eu-west-1.rds.amazonaws.com"`)
4. **Failover disparado por el estudiante** ✅ (evento CloudTrail `RebootDBInstance` con `forceFailover: true`)

## Nota sobre el entorno del sandbox

La base de datos `taskdb.addressbook` que el enunciado decía "pre-creada con datos de muestra" en realidad no existía al iniciar la tarea — ambas aplicaciones (`data-generator` y `data-collector`) fallaban con `Unknown database 'taskdb'`. Se creó manualmente el schema y la tabla contra el primario antes de continuar (ver práctica). El cliente `mysql` tampoco venía preinstalado en la instancia EC2 — se instaló vía `mariadb105`, igual que en el lab 7.1.

## Recursos

Al finalizar se usó el botón **"Destroy Resources"** de la plataforma.
