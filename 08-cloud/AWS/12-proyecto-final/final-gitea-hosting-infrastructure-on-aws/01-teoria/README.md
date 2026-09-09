# Teoría — Final Task: Implement Gitea Hosting Infrastructure on AWS

Proyecto de cierre del bootcamp: una plantilla de CloudFormation "de producción" que combina prácticamente todos los módulos anteriores — networking (VPC/NAT/rutas), balanceo de carga, base de datos administrada, almacenamiento compartido, auto scaling, IAM, y observabilidad — para alojar una aplicación real (Gitea) con Docker Compose.

## Rol de ejecución de CloudFormation vs. rol de los recursos que crea

Igual que en el lab de CloudFormation básico (módulo 6), este proyecto usa **dos roles IAM completamente distintos y sin relación entre sí**:
- El rol que **CloudFormation asume** (`--role-arn`) para tener permiso de crear/modificar los recursos del stack.
- El rol `cmtr-iacp1ebx-role`, **creado por el propio stack**, que las instancias EC2 asumirán en tiempo de ejecución (para SSM y para que el script de `UserData` pueda consultar RDS/ALB/EFS vía AWS CLI).

## Arquitectura de red: por qué las instancias van en subnets privadas

El ALB vive en las subnets **públicas** (necesita ser accesible desde internet), pero las instancias EC2, RDS y los mount targets de EFS viven en subnets **privadas** — el tráfico de usuarios entra por el ALB, que reenvía a las instancias privadas; las instancias salen a internet (para `dnf update`, descargar `docker-compose`, o consultar la API de AWS) a través del **NAT Gateway**, sin exponer una IP pública directa. Esta es la razón de ser del NAT Gateway en el diseño: sin él, las instancias en subnets privadas no tendrían forma de alcanzar internet.

## `docker-compose.yml` generado dinámicamente en el arranque, no incluido en la plantilla

El `UserData` de la Launch Template no contiene un `docker-compose.yml` estático — lo **genera en tiempo de ejecución**, interpolando el endpoint real de RDS y el DNS real del ALB (obtenidos vía `aws rds describe-db-instances` y `aws elbv2 describe-load-balancers`, gracias a que el rol de instancia tiene permisos amplios). Esto resuelve un problema de "huevo y gallina": la plantilla de CloudFormation no puede conocer de antemano el `ROOT_URL` del ALB para inyectarlo como variable de plantilla, porque el ALB y las instancias se crean como parte del mismo stack — resolverlo en tiempo de arranque (vía API calls) es más simple que intentar orquestar el orden exacto de creación con `DependsOn` y pasar el valor por `UserData` con `Fn::Sub`.

## El punto crítico no documentado: `/data/gitea/conf/app.ini` se lee solo al arrancar el proceso

El `docker-compose.yml` monta `/gitea` (host, en EFS) como `/data` (contenedor) — por lo tanto **ambas** instancias del ASG comparten el mismo `app.ini` de configuración (incluida la bandera `INSTALL_LOCK`) vía el mismo sistema de archivos EFS. Sin embargo, cada proceso Gitea (uno por instancia EC2) **lee `app.ini` una sola vez, al arrancar**, y lo mantiene en memoria — no lo re-lee en caliente. Si las dos instancias arrancan sus contenedores en momentos ligeramente distintos (lo cual es casi garantizado, ya que cada una ejecuta su propio `UserData` de forma independiente), es posible que **solo una** de las dos haya completado el asistente de instalación web cuando la otra ya arrancó su propio proceso Gitea leyendo un `app.ini` todavía sin `INSTALL_LOCK` — resultando en dos instancias con comportamiento inconsistente (una "instalada", otra no) detrás del mismo ALB, incluso compartiendo la misma base de datos MySQL. La única forma de resincronizarlas es **reiniciar el proceso** (`docker-compose restart`) en la instancia que quedó desactualizada, forzándola a releer el `app.ini` ya actualizado.

## Sesiones no compartidas entre instancias sin Sticky Sessions

Por defecto, Gitea usa un almacén de sesiones en memoria/proceso (no configurado explícitamente para usar la base de datos compartida) — cada instancia del ASG mantiene sus propias sesiones de usuario autenticado, independientes entre sí. Con un Application Load Balancer haciendo *round-robin* entre 2 instancias sin *stickiness*, cada request HTTP nueva tiene ~50% de probabilidad de aterrizar en una instancia distinta a la anterior, invalidando aparentemente la sesión del usuario a mitad de un flujo (ej. login exitoso seguido de un "no autenticado" en la siguiente página). Habilitar **stickiness basado en cookie** (`stickiness.enabled=true`, `stickiness.type=lb_cookie`) en el Target Group resuelve esto para el flujo de configuración manual, fijando al navegador a la misma instancia durante la sesión — sin tocar el código de la aplicación ni la arquitectura del stack.
