# Teoría — Launch Templates, User Data y Auto Scaling Groups

## Launch Templates y versionado

Un **Launch Template** define la configuración con la que se lanzan instancias EC2 (AMI, tipo de instancia, user data, security groups, etc.) — es la evolución de las "Launch Configurations" y, a diferencia de estas, sí soporta **versionado**: cada cambio (`create-launch-template-version`) crea una nueva versión numerada, sin sobrescribir las anteriores. Una plantilla puede tener designada una versión como:
- **Default** (`$Default`): la que se usa cuando algo referencia la plantilla sin especificar versión explícita.
- **Latest** (`$Latest`): siempre la más reciente creada, se mueve automáticamente con cada nueva versión.

Un Auto Scaling Group puede apuntar a `$Default`, `$Latest`, o a un número de versión fijo. En este lab, el ASG usa `$Default` — por eso el segundo movimiento (aparte de crear la nueva versión con el user data corregido) es marcar esa nueva versión como la default (`modify-launch-template --default-version`), sin lo cual el ASG seguiría lanzando instancias con la versión vieja.

## User Data + Instance Metadata Service (IMDS)

El script de `--user-data` se ejecuta una sola vez, en el primer arranque de la instancia (vía `cloud-init`). Para que el mensaje mostrado incluya el **IP público real** y el **Instance ID real** de cada instancia (valores que no se conocen de antemano, distintos para cada instancia que lance el Auto Scaling Group), el script debe consultarlos en tiempo de ejecución contra el **Instance Metadata Service** (`169.254.169.254`) — un endpoint local, no enrutable fuera de la instancia, que expone metadata de la instancia en la que corre.

Con **IMDSv2** (el estándar actual, más seguro que IMDSv1) hay que primero solicitar un token de sesión antes de poder consultar cualquier endpoint de metadata:
```bash
TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
INSTANCE_ID=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/instance-id)
PUBLIC_IP=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/public-ipv4)
```

## Auto Scaling Group — Instance Refresh

Cambiar la versión default de un Launch Template **no afecta a las instancias ya corriendo** — solo aplica a las que se lancen de ahí en adelante. Para forzar que un ASG reemplace sus instancias actuales por otras con la configuración nueva (sin esperar a un evento de scaling natural), se usa un **Instance Refresh** (`start-instance-refresh`): reemplaza las instancias del grupo de forma gradual (controlado por un "min healthy percentage"), preservando la disponibilidad del servicio durante el proceso. Es el mecanismo por el cual la instancia de ejemplo original de este lab "se destruye" al verificar la tarea — el refresh la reemplaza por una nueva, ya con el user data correcto.
