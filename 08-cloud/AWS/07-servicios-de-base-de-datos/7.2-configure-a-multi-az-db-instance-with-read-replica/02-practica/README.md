# Práctica — Configure a Multi-AZ DB Instance with Read-Replica

## Enunciado de la tarea

> Convert an existing single-AZ RDS instance into Multi-AZ, create a read-replica named `db-replica`, point the `data-collector` app to the replica endpoint, and trigger + validate a failover while `data-generator` keeps writing.

**Región:** `eu-west-1` — Cuenta `180294176810`

**Recursos pre-creados por el stack del sandbox:**
- RDS Instance (identificador real `cmtr-iacp1ebx-rds-madi-rds-2770760-primary`; el enunciado lo listaba por su `DbiResourceId`, `db-6TE3SW4BYSKZYXS34ELID5VJYE` — ver incidente más abajo)
- EC2 Instance `i-0fe3fdf9012586d55` (Amazon Linux 2023) con dos apps: `data-collector` (puerto 8080, `/usr/local/bin/data-collector`) y `data-generator` (`/usr/local/bin/data-generator`)
- Security Groups `sg-0008d10677ac5ccf8` (EC2, 8080 abierto) y `sg-0f4c07042960fac55` (RDS, 3306 desde el SG de EC2)
- IAM Role con acceso SSM para la instancia EC2

**Entorno real usado:** CLI local (Git Bash en Windows) — CloudShell bloqueado por SCP, igual que en labs anteriores.

---

## Incidente: identificador de la tarea no reconocido por la API

```
An error occurred (DBInstanceNotFound) when calling the ModifyDBInstance operation:
DB instance not found: db-6te3sw4byskzyxs34elid5vjye
```
El enunciado listaba la instancia como `db-6TE3SW4BYSKZYXS34ELID5VJYE`, pero ese valor resultó ser el `DbiResourceId` (identificador interno inmutable), no el `DBInstanceIdentifier`. **Fix**: `aws rds describe-db-instances --query 'DBInstances[].[DBInstanceIdentifier,DBInstanceStatus,Engine]' --output table` reveló el nombre real: `cmtr-iacp1ebx-rds-madi-rds-2770760-primary`.

## Movimiento 1 — Convertir a Multi-AZ

```bash
aws rds modify-db-instance \
  --db-instance-identifier cmtr-iacp1ebx-rds-madi-rds-2770760-primary \
  --multi-az \
  --apply-immediately

aws rds wait db-instance-available --db-instance-identifier cmtr-iacp1ebx-rds-madi-rds-2770760-primary
```

## Movimiento 2 — Crear el read-replica

```bash
aws rds create-db-instance-read-replica \
  --db-instance-identifier db-replica \
  --source-db-instance-identifier cmtr-iacp1ebx-rds-madi-rds-2770760-primary \
  --db-instance-class db.t3.micro \
  --no-publicly-accessible \
  --monitoring-interval 0

aws rds wait db-instance-available --db-instance-identifier db-replica
REPLICA_ENDPOINT=$(aws rds describe-db-instances --db-instance-identifier db-replica --query 'DBInstances[0].Endpoint.Address' --output text)
```
`--monitoring-interval 0` corresponde a dejar desmarcado "Enable Enhanced Monitoring" que pide el enunciado. La clase de instancia (`db.t3.micro`) se igualó a la del primario.

## Incidente: Session Manager plugin no instalado localmente

```
aws: [ERROR]: SessionManagerPlugin is not found.
```
Igual que en labs anteriores, hacía falta instalar el plugin en la máquina Windows:
```bash
curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/windows/SessionManagerPluginSetup.exe" -o "$TEMP/SessionManagerPluginSetup.exe"
"$TEMP/SessionManagerPluginSetup.exe"
```
Tras completar el wizard gráfico, hubo que **cerrar y reabrir Git Bash por completo** (no solo una pestaña) para que tomara el PATH actualizado.

## Movimiento 3 — Reconfigurar `data-collector`

```bash
aws ssm start-session --target i-0fe3fdf9012586d55
```
Dentro de la instancia:
```bash
sudo grep -n ENDPOINT /usr/local/bin/data-collector
sudo sed -i '2s/.*/ENDPOINT="db-replica.clw26o2smg1o.eu-west-1.rds.amazonaws.com"/' /usr/local/bin/data-collector
sudo systemctl restart data-collector
```

## Incidente: `mysql: command not found` en ambas apps + base de datos `taskdb` inexistente

El log de `data-generator` mostraba fallos consistentes:
```
.../data-generator: line 10: mysql: command not found
...
ERROR 1049 (42000) at line 2: Unknown database 'taskdb'
```
Dos problemas distintos, en cascada:
1. **Cliente MySQL no instalado** en la instancia — se resolvió con `sudo dnf install -y mariadb105` (igual que en el lab 7.1).
2. **La base `taskdb` nunca existió** en la instancia RDS, pese a que el enunciado decía "containing a pre-created database with a table and sample data" — un fallo de aprovisionamiento del propio sandbox, no un error del estudiante. Se creó manualmente contra el **primario** (las escrituras deben ir ahí, no al replica):
```bash
mysql -h cmtr-iacp1ebx-rds-madi-rds-2770760-primary.clw26o2smg1o.eu-west-1.rds.amazonaws.com -P 3306 -u admin -pXAiYdWbm_dzD362z -e "CREATE DATABASE IF NOT EXISTS taskdb; USE taskdb; CREATE TABLE IF NOT EXISTS addressbook (id INT AUTO_INCREMENT PRIMARY KEY, name VARCHAR(255), address VARCHAR(255), created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP); INSERT INTO addressbook (name, address) VALUES ('SeedUser','SeedAddress');"
```
Tras esto, `data-generator` empezó a insertar exitosamente cada 60s, y el log de `data-collector` (contra el replica) reflejó los mismos registros tras la replicación asíncrona (segundos de rezago).

## Movimiento 4 — Failover

```bash
aws rds reboot-db-instance --db-instance-identifier cmtr-iacp1ebx-rds-madi-rds-2770760-primary --force-failover
aws rds wait db-instance-available --db-instance-identifier cmtr-iacp1ebx-rds-madi-rds-2770760-primary
```

### Incidente: `AccessDenied` al correr el failover desde dentro de la sesión SSM

```
User: .../assumed-role/cmtr-iacp1ebx-rds-madi-iam_role/i-0fe3fdf9012586d55 is not authorized
to perform: rds:RebootDBInstance
```
El rol de instancia EC2 solo tiene permisos de SSM, no de RDS. **Fix**: correr el comando desde la terminal local (credenciales de sandbox del usuario), no desde dentro de la sesión SSM.

## Verificación

```bash
aws rds describe-events --source-identifier cmtr-iacp1ebx-rds-madi-rds-2770760-primary --source-type db-instance --duration 30 --query 'Events[].[Date,Message]' --output table
```
Confirmó `Multi-AZ instance failover started` → `Multi-AZ instance failover completed`. El log de `data-generator` no mostró ningún corte durante la ventana del failover (inserciones exitosas cada 60s, sin gaps).
