# Resultados — Update ECS Task to a New Docker Image Version

**Estado:** ✅ Tarea completada y verificada por la plataforma (incluye bonus de uso de CLI, coeficiente 1.0)

## Resumen de los recursos configurados

| Recurso | Configuración |
|---|---|
| Servicio | `ECS_task_update_service`, task definition final `nginx_v2:2` |
| Tarea vieja | `nginx_v1:2` desregistrada (`INACTIVE`) |
| Verificación | `http://3.253.138.202` sirve "CLOUDMENTOR ECS Task Update — Version_2" |

## Verificación automática de la plataforma

1. **Versión 2 corriendo en el puerto 80 de la IP pública** ✅
2. **Bonus por uso de CLI** ✅ (coeficiente 1.0)

## Aprendizaje clave

En un cluster con una sola instancia EC2 y `hostPort` fijo, un `update-service --force-new-deployment` estándar puede quedar atascado por conflicto de puerto entre el deployment viejo y el nuevo. La solución confiable es escalar el servicio a 0 réplicas y volver a escalarlo a la cuenta deseada especificando la nueva task definition — evita la competencia entre deployments por el mismo puerto/instancia.

## Recursos

Al finalizar se usó el botón **"Destroy Resources"** de la plataforma.
