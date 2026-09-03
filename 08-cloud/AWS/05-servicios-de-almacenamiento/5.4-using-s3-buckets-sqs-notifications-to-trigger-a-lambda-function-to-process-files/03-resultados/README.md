# Resultados — Using S3 Bucket's SQS Notifications to Trigger a Lambda Function

**Estado:** ✅ Tarea completada y verificada por la plataforma (4/4 checks aprobados)

## Resumen de los recursos configurados

| Recurso | Configuración |
|---|---|
| Bucket → SQS | Notificación `s3:ObjectCreated:*`, prefijo `input/`, destino `cmtr-iacp1ebx-s3-snlt-queue` |
| Lambda ← SQS | Event source mapping `179e2bfc-a7e5-47f6-abeb-197b22561ffd`, `BatchSize: 10`, `State: Enabled` |
| Archivos procesados | `output/lambdahandled_input/sample.txt`, `output/lambdahandled_input/test_object_key.txt` (este último generado por el propio "Check" de la plataforma) |

## Verificación automática de la plataforma

1. **Notificación SQS agregada al bucket** ✅ — `QueueConfigurations` con el `QueueArn` correcto
2. **Lambda tiene a SQS como event source** ✅ — `State: Enabled`
3. **Archivo presente en `output/`** ✅ — se ven tanto el archivo de prueba propio como uno generado por la validación de la plataforma, confirmando que el pipeline procesa cualquier subida a `input/` de forma consistente
4. **Bono por uso de CLI** ✅ — coeficiente 1.0

## Recursos destruidos

Al finalizar se usó el botón **"Destroy Resources"** de la plataforma.
