# Teoría — Update ECS Task to a New Docker Image Version

## El deployment "viejo" no desaparece solo con `force-new-deployment`

Al actualizar un servicio ECS a una nueva task definition, ECS no reemplaza la tarea vieja instantáneamente — crea un **nuevo deployment** (`PRIMARY`) y mantiene el anterior como `ACTIVE` mientras haga falta, cada uno con su propio `desiredCount` gestionado de forma independiente por el scheduler. Con `hostPort` fijo y una sola instancia de capacidad, ambos deployments "compiten" por el mismo puerto — y mientras el deployment viejo siga `ACTIVE` con `desiredCount > 0`, el scheduler seguirá relanzando tareas de la versión vieja para satisfacerlo, incluso si se detiene manualmente una tarea suya (`stop-task` solo mata la tarea puntual, no reduce el `desiredCount` del deployment que la originó).

## `deregister-task-definition` no impide que un deployment activo la siga usando

Marcar una revisión de task definition como `INACTIVE` evita que se pueda **crear una tarea nueva especificándola explícitamente**, pero **no** impide que un deployment de servicio que ya la tenía asignada internamente la siga usando para relanzar tareas de reemplazo — el deployment guarda su propia referencia interna, independiente del estado de la task definition. Por eso, en este lab, incluso tras desregistrar `nginx_v1:2`, el scheduler seguía arrancando tareas `nginx_v1` para satisfacer el deployment `ACTIVE` viejo.

## El fix confiable: escalar a 0 y volver a escalar

La forma robusta de resolver un conflicto de puerto/capacidad entre deployments en un cluster de una sola instancia es:
1. `update-service --desired-count 0` — esto fuerza a **ambos** deployments (viejo y nuevo) a bajar su `desiredCount` a 0, liberando por completo el puerto/recursos.
2. `update-service --desired-count 1 --task-definition <nueva>` — al volver a escalar, ya no queda ningún deployment viejo compitiendo; solo se crea uno nuevo apuntando exclusivamente a la revisión deseada.

Es más determinista que intentar "matar" tareas puntuales mientras el servicio sigue con deployments duales activos.

## `availabilityZoneRebalancing: ENABLED` restringe la configuración de deployment

Cuando el rebalanceo de AZ está habilitado en el servicio, ECS exige `maximumPercent > 100` en la configuración de deployment (para poder mover tareas entre AZs sin downtime) — intentar bajar `maximumPercent` a 100 o menos (como para forzar un "replace" en vez de "add then remove") falla con `InvalidParameterException`. Esto descarta la táctica de bajar `minimumHealthyPercent`/`maximumPercent` como solución en clusters con este flag activo, reforzando que el enfoque de escalar a 0 y volver a subir es más portable entre configuraciones.
