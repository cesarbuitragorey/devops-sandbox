# Práctica — Update ECS Task to a New Docker Image Version

## Enunciado de la tarea

> Update the `ECS_task_update_service` service to deploy the `v2` Docker image on the single EC2 instance registered in the ECS cluster.

**Región:** `eu-west-1` — Cuenta `481665110417`

**Recursos pre-desplegados:** cluster `cmtr-iacp1ebx-ecs-tu-ecs_cluster`, ECR `cmtr-iacp1ebx-ecs-tu-ecr_repository` (tags `v1`/`v2`), servicio `ECS_task_update_service` (capacity provider `ec2`), task definitions `nginx_v1`/`nginx_v2`, EC2 con IP pública `3.253.138.202` corriendo `v1`.

**Entorno real usado:** CLI local (Git Bash).

---

## Movimiento 1 — Identificar la task definition destino y actualizar el servicio

```bash
aws ecs list-task-definitions --family-prefix nginx_v2 --sort DESC --query 'taskDefinitionArns[0]'
# nginx_v2:2

aws ecs update-service \
  --cluster cmtr-iacp1ebx-ecs-tu-ecs_cluster \
  --service ECS_task_update_service \
  --task-definition nginx_v2:2 \
  --force-new-deployment \
  --region eu-west-1
```

## Incidente: rolling update atascado — conflicto de puerto en cluster de 1 instancia

El nuevo deployment quedó indefinidamente en `IN_PROGRESS`:
```
was unable to place a task because no container instance met all of its requirements.
The closest matching (container-instance ...) is already using a port required by your task.
```

### Intento 1 (fallido): bajar `minimumHealthyPercent`/`maximumPercent`
```
InvalidParameterException: Availability Zone Rebalancing does not support maximumPercent <= 100%
```
El servicio tiene `availabilityZoneRebalancing: ENABLED`, que exige `maximumPercent > 100`.

### Intento 2 (parcialmente fallido): `stop-task` manual + `deregister-task-definition`
Detener la tarea vieja manualmente no funcionó — el deployment `ACTIVE` viejo (con su propio `desiredCount: 1`) relanzaba otra tarea `nginx_v1` de inmediato para mantenerse. Desregistrar `nginx_v1:2` (`INACTIVE`) tampoco lo evitó: un deployment ya en curso puede seguir relanzando tareas de una revisión inactiva, ya que guarda su propia referencia interna independiente del estado de la task definition.

### Fix definitivo: escalar a 0 y volver a escalar
```bash
aws ecs update-service --cluster cmtr-iacp1ebx-ecs-tu-ecs_cluster --service ECS_task_update_service --desired-count 0 --region eu-west-1
# esperar a que ambos deployments (viejo y nuevo) bajen a 0 tareas corriendo

aws ecs update-service --cluster cmtr-iacp1ebx-ecs-tu-ecs_cluster --service ECS_task_update_service --desired-count 1 --task-definition nginx_v2:2 --region eu-west-1
```
Al escalar a 0 primero, se elimina la competencia entre deployments por el puerto — al volver a subir a 1, solo existe un deployment (el nuevo), que se coloca sin conflicto.

## Verificación

```bash
curl http://3.253.138.202
```
Devolvió la página "CLOUDMENTOR ECS Task Update — Version_2".
