# Práctica — Setup a Simple Task in a Custom ECS Anywhere Cluster

## Enunciado de la tarea

> Create an ECS cluster, register a pre-deployed EC2 instance as an ECS Anywhere external instance, and deploy an nginx task (family `nginx-ecs`) via an EXTERNAL-launch-type service, accessible on host port 5050.

**Región:** `eu-west-1` — Cuenta `762233765440`

**Recursos pre-desplegados:** EC2 `cmtr-iacp1ebx-ec2` (`i-0e6d0d42b17d95246`, IP pública `34.249.140.58`, SG con 5050 ya abierto a `0.0.0.0/0`).

**Entorno real usado:** CLI local (Git Bash) para los comandos de AWS, EC2 Instance Connect para la instancia "externa".

---

## Movimiento 1 — Cluster, roles IAM y activación SSM

```bash
aws ecs create-cluster --cluster-name cmtr-iacp1ebx-cluster --capacity-providers FARGATE FARGATE_SPOT --region eu-west-1
```

`ecsExternalInstanceRole` (trust `ssm.amazonaws.com` + `AmazonEC2ContainerServiceforEC2Role` + `AmazonSSMManagedInstanceCore`) y `ecsTaskExecutionRole` (trust `ecs-tasks.amazonaws.com` + `AmazonECSTaskExecutionRolePolicy`) se crearon igual que en el lab 8.1 y en labs anteriores del bootcamp.

```bash
aws ssm create-activation --iam-role ecsExternalInstanceRole --registration-limit 1 --region eu-west-1
```

## Movimiento 2 — Conectar a la instancia EC2 y registrarla

```bash
aws ec2-instance-connect ssh --instance-id i-0e6d0d42b17d95246 --os-user ec2-user
```

Dentro de la instancia:
```bash
curl --proto "https" -o "/tmp/ecs-anywhere-install.sh" "https://amazon-ecs-agent.s3.amazonaws.com/ecs-anywhere-install-latest.sh"
sudo bash /tmp/ecs-anywhere-install.sh --region eu-west-1 --cluster cmtr-iacp1ebx-cluster --activation-id <id> --activation-code <code>
```

### Incidente: verificación GPG falla por falta de `gpg-agent` (Amazon Linux 2023)

El script se detenía silenciosamente tras verificar la firma del paquete `amazon-ecs-init`:
```
gpg: error running '/usr/bin/gpg-agent': probably not installed
gpg: failed to start gpg-agent '/usr/bin/gpg-agent': Configuration error
```
AL2023 trae `gnupg2-minimal` por defecto, que no incluye `gpg-agent`. **Fix**:
```bash
sudo dnf swap gnupg2-minimal gnupg2 -y
```
Tras esto, reintentar el mismo comando del instalador completó exitosamente (detectó SSM/Docker ya instalados de un intento previo, e instaló `amazon-ecs-init` sin problema), terminando con `Ping ECS Agent registered successfully!`.

## Movimiento 3 — Task Definition (CPU/memoria a nivel de contenedor)

```bash
cat > nginx-task-def.json << 'EOF'
{
  "family": "nginx-ecs",
  "requiresCompatibilities": ["EXTERNAL"],
  "networkMode": "bridge",
  "executionRoleArn": "arn:aws:iam::762233765440:role/ecsTaskExecutionRole",
  "containerDefinitions": [
    {
      "name": "iacp1ebx-nginx",
      "image": "nginx",
      "essential": true,
      "cpu": 256,
      "memory": 512,
      "portMappings": [
        {"containerPort": 80, "hostPort": 5050, "protocol": "tcp"}
      ]
    }
  ]
}
EOF

aws ecs register-task-definition --cli-input-json file://nginx-task-def.json --region eu-west-1
```

### Incidente: primer intento con `cpu`/`memory` solo a nivel de tarea

Un primer registro (revisión 7) puso `"cpu": "256"` y `"memory": "512"` como campos de **tarea** (top-level), dejando el contenedor sin esos valores (`cpu: 0`, sin `memory`). El check de la plataforma "Check task definition CPU/memory is set" falló, esperando esos valores **dentro de `containerDefinitions`**. **Fix**: revisión 8, con `cpu`/`memory` movidos al nivel del contenedor.

## Movimiento 4 — Servicio ECS (launch type EXTERNAL)

```bash
aws ecs create-service \
  --cluster cmtr-iacp1ebx-cluster \
  --service-name nginx-service \
  --task-definition nginx-ecs \
  --desired-count 1 \
  --launch-type EXTERNAL \
  --region eu-west-1
```

### Incidente: rolling update atascado por puerto/memoria insuficiente en una sola instancia

Al actualizar el servicio a la revisión 8 (`update-service --force-new-deployment`), el nuevo deployment quedó en `IN_PROGRESS` indefinidamente:
```
was unable to place a task because no container instance met all of its requirements.
The closest matching (container-instance ...) has insufficient memory available.
```
Con `hostPort` fijo (5050) y una sola external instance, la tarea vieja y la nueva no caben simultáneamente (conflicto de puerto + memoria). **Fix**:
1. `aws ecs update-service --deployment-configuration minimumHealthyPercent=0,maximumPercent=100` (permite 0 tareas sanas temporalmente).
2. `aws ecs stop-task` manual sobre la tarea de la revisión vieja, liberando el puerto/memoria para que la nueva pudiera colocarse.

## Verificación

```bash
curl http://34.249.140.58:5050
```
Devolvió la página de bienvenida de nginx.
