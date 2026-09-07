# Teoría — Setup a Simple Task in a Custom ECS Anywhere Cluster

## CPU/memoria a nivel de tarea vs. a nivel de contenedor

En una task definition de ECS, `cpu`/`memory` pueden declararse en dos niveles:
- **A nivel de tarea** (top-level `cpu`/`memory`, como string) — obligatorio en Fargate (define el tamaño total de la "caja" que se factura), opcional en EC2/External.
- **A nivel de contenedor** (dentro de `containerDefinitions[].cpu`/`memory`, como número) — define cuánto de esos recursos reserva/limita ese contenedor específico dentro del host.

Para EXTERNAL (igual que EC2), solo el nivel de contenedor determina cuánta capacidad del host reserva la tarea al momento de hacer scheduling — el nivel de tarea es más bien informativo/opcional en este modo. Declarar `cpu`/`memory` solo a nivel de tarea (sin especificarlo en el contenedor) deja el contenedor con `cpu: 0`/sin `memory`, lo cual puede pasar checks de "task-level" pero fallar verificaciones que inspeccionan específicamente la configuración del contenedor.

## `bridge` network mode + `hostPort` fijo = capacidad limitada a 1 tarea por instancia

Con `networkMode: bridge` y un `hostPort` estático (aquí, 5050), solo **una** tarea puede tener ese puerto reservado en un host dado a la vez — a diferencia de `hostPort: 0` (puerto dinámico), que permitiría múltiples réplicas del mismo servicio en la misma instancia. Esto tiene una consecuencia directa en despliegues (deployments) de un servicio: con un único external instance y un puerto fijo, **no caben simultáneamente la tarea vieja y la nueva** durante un rolling update — un update por defecto (`minimumHealthyPercent: 100`, `maximumPercent: 200`) intenta arrancar la nueva antes de matar la vieja, lo cual se traba indefinidamente por conflicto de puerto/memoria insuficiente en una sola instancia.

**Fix aplicado**: bajar `minimumHealthyPercent` a 0 (permite 0 tareas sanas temporalmente) y detener manualmente la tarea vieja para liberar el puerto/memoria antes de que la nueva pueda colocarse.

## Recursos "registrados" de una instancia externa vs. recursos reales del host

ECS Anywhere registra la instancia con una capacidad de CPU/memoria basada en lo que detecta el agente ECS al arrancar — dos tareas que en conjunto exceden esa capacidad "registrada" (aunque el host físico tenga RAM libre real) generan el evento `insufficient memory available` al intentar colocar (`place`) una tarea nueva. Es la misma lógica de scheduling que en un cluster EC2 tradicional, solo que aplicada a un único nodo externo en vez de un Auto Scaling Group.

## Un mismo cluster con dos ejercicios distintos

Este lab reutiliza el mismo cluster `cmtr-iacp1ebx-cluster` y el mismo rol `ecsExternalInstanceRole` que el lab 8.1, pero en una instancia EC2 pre-desplegada (simulando "on-premise") en vez de una VM local — demostrando que el registro de instancias externas es agnóstico al tipo real de máquina, siempre que cumpla los requisitos técnicos (SO soportado, `systemd`, Docker, conectividad saliente).
