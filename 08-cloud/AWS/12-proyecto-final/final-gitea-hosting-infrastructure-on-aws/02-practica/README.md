# Práctica — Final Task: Implement Gitea Hosting Infrastructure on AWS

## Enunciado de la tarea

> Deploy Gitea on AWS via a self-authored CloudFormation template (VPC, ALB, RDS MySQL, EFS, ASG with a Launch Template running Gitea in Docker Compose, CloudWatch dashboard), then configure Gitea through the ALB: create a user `giteauser` and a first repo `awsgiteaproject`.

**Región:** `eu-west-1` — Cuenta `039612868287`

**Entorno real usado:** plantilla YAML escrita localmente ([`cmtr-iacp1ebx-final.yml`](cmtr-iacp1ebx-final.yml)), desplegada vía CLI local (Git Bash); configuración final de Gitea vía navegador (Browser tool).

---

## Movimiento 1 — Rol de ejecución de CloudFormation

```bash
cat > cfn-trust-policy.json << 'EOF'
{"Version":"2012-10-17","Statement":[{"Effect":"Allow","Principal":{"Service":"cloudformation.amazonaws.com"},"Action":"sts:AssumeRole"}]}
EOF
aws iam create-role --role-name cmtr-iacp1ebx-cfn-role --assume-role-policy-document file://cfn-trust-policy.json
aws iam attach-role-policy --role-name cmtr-iacp1ebx-cfn-role --policy-arn arn:aws:iam::aws:policy/AdministratorAccess
```

## Movimiento 2 — Plantilla y despliegue del stack

Ver [`cmtr-iacp1ebx-final.yml`](cmtr-iacp1ebx-final.yml) — plantilla completa con VPC de 2 AZs (2 subnets públicas + 2 privadas), IGW, NAT Gateway (en la subnet pública 1), tablas de rutas, 4 security groups, ALB + Target Group + Listener + Listener Rule, RDS MySQL `db.t3.micro`, EFS con 2 mount targets, rol/instance profile IAM para EC2, Launch Template (con el `UserData` provisto en el enunciado, sin modificar), Auto Scaling Group (min 2 / max 4), política de escalado por `ALBRequestCountPerTarget`, y dashboard de CloudWatch con las 5 métricas pedidas.

```bash
aws cloudformation validate-template --template-body file://cmtr-iacp1ebx-final.yml

aws cloudformation create-stack \
  --stack-name cmtr-iacp1ebx-final \
  --template-body file://cmtr-iacp1ebx-final.yml \
  --role-arn arn:aws:iam::039612868287:role/cmtr-iacp1ebx-cfn-role \
  --capabilities CAPABILITY_NAMED_IAM \
  --region eu-west-1

aws cloudformation wait stack-create-complete --stack-name cmtr-iacp1ebx-final --region eu-west-1
```
`CREATE_COMPLETE` en ~15 minutos (dominado por RDS). Outputs: `ALBDNSName`, `RDSEndpoint`, `EFSId`.

## Movimiento 3 — Verificar salud de las instancias

```bash
aws elbv2 describe-target-health --target-group-arn $(aws elbv2 describe-target-groups --names cmtr-iacp1ebx-tg --region eu-west-1 --query 'TargetGroups[0].TargetGroupArn' --output text) --region eu-west-1
```
Ambas instancias `healthy` tras ~2 minutos (tiempo del `UserData`: instalar Docker, montar EFS, generar `docker-compose.yml`, levantar el contenedor).

## Movimiento 4 — Instalación de Gitea vía navegador

Con el ALB DNS, se abrió `http://<alb-dns>/` — el asistente de instalación de Gitea ya traía los campos de base de datos **pre-poblados** correctamente desde las variables de entorno del contenedor (`DB_TYPE`, `DB_HOST`, `DB_USER`, `DB_PASSWD`, `DB_NAME`). Se omitió la cuenta de administrador en el instalador (opcional) y se hizo clic en "Instalar Gitea".

## Incidente: dos instancias del ASG con estado inconsistente (una "instalada", otra no)

Tras registrar el primer usuario, la navegación a `/user/login` y `/repo/create` devolvía intermitentemente `404` o la página pública de marketing (no autenticada) — confirmado en `read_network_requests`: `GET /user/login → 404 Not Found`.

**Causa raíz**: ambas instancias EC2 montan el mismo EFS (`/gitea` → `/data` en el contenedor), por lo que comparten el mismo `app.ini` (incluida la bandera de instalación). Pero cada proceso Gitea solo **lee `app.ini` al arrancar**, no en caliente — como cada instancia ejecuta su propio `UserData` de forma independiente, es posible que solo una hubiera completado el asistente web cuando la otra ya había arrancado su contenedor con una config sin `INSTALL_LOCK`. El ALB, sin *stickiness*, alternaba entre una instancia "instalada" y otra desactualizada.

**Fix**:
```bash
aws elbv2 modify-target-group-attributes \
  --target-group-arn <tg-arn> \
  --attributes Key=stickiness.enabled,Value=true Key=stickiness.type,Value=lb_cookie Key=stickiness.lb_cookie.duration_seconds,Value=3600 \
  --region eu-west-1

aws ssm send-command \
  --instance-ids <instance-1> <instance-2> \
  --document-name "AWS-RunShellScript" \
  --parameters 'commands=["cd /gitea","sudo docker-compose restart"]' \
  --region eu-west-1
```
El *restart* fuerza a ambos procesos Gitea a releer el `app.ini` ya actualizado desde EFS, dejando las dos instancias consistentes; el *stickiness* evita que el ALB alterne de instancia durante el flujo de configuración manual (login → crear repo).

## Movimiento 5 — Registrar `giteauser` y crear `awsgiteaproject`

Tras el fix, `/user/login` cargó correctamente. El primer intento de login con las credenciales usadas en el registro anterior falló ("nombre de usuario o contraseña incorrectos") — confirmando que ese registro previo había caído en la instancia todavía no instalada y nunca llegó a persistirse en RDS. Se registró `giteauser` de nuevo (confirmado por el mensaje "You are registering the first account in the system, which has administrator privileges"), y se creó el repositorio `awsgiteaproject` desde `/repo/create`.

## Verificación

- `curl` al ALB DNS → `200`.
- `giteauser/awsgiteaproject` visible y accesible tras la creación.
- En una instancia EC2 (vía SSM): `/gitea/git/repositories/giteauser/awsgiteaproject.git` contiene la estructura de un repo bare de Git (`HEAD`, `config`, `objects/`, `refs/`, etc.), confirmando persistencia real en EFS.
