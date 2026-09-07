# Resultados — Setup a Simple Task in a Custom ECS Anywhere Cluster

**Estado:** ✅ Tarea completada y verificada por la plataforma (11/11 checks aprobados)

## Resumen de los recursos configurados

| Recurso | Configuración |
|---|---|
| Cluster ECS | `cmtr-iacp1ebx-cluster` |
| Roles IAM | `ecsExternalInstanceRole`, `ecsTaskExecutionRole` (con `AmazonECSTaskExecutionRolePolicy`) |
| Instancia externa | EC2 `i-0e6d0d42b17d95246` registrada como external instance vía ECS Anywhere |
| Task Definition | `nginx-ecs` (rev. 8), `EXTERNAL`, `bridge`, contenedor `iacp1ebx-nginx` (`nginx`, cpu 256, memory 512, 80→5050/tcp) |
| Servicio | `nginx-service`, launch type `EXTERNAL`, 1 tarea `RUNNING` |

## Verificación automática de la plataforma

1. **Container instance conectada** ✅
2. **Tarea ECS `RUNNING`** ✅
3. **Tipo `EXTERNAL`** ✅
4. **Nombre del contenedor correcto** ✅
5. **Familia de task definition correcta** ✅
6. **Network mode `bridge`** ✅
7. **Container port `80`** ✅
8. **Host port `5050`** ✅
9. **Protocolo `tcp`** ✅
10. **CPU configurado (a nivel de contenedor)** ✅
11. **Memoria configurada (a nivel de contenedor)** ✅

## Aprendizaje clave

Con `hostPort` fijo y una sola external instance, los rolling updates del servicio requieren `minimumHealthyPercent: 0` y a veces detener manualmente la tarea vieja — no hay capacidad para correr ambas versiones a la vez en un solo nodo.

## Recursos

Al finalizar se usó el botón **"Destroy Resources"** de la plataforma.
