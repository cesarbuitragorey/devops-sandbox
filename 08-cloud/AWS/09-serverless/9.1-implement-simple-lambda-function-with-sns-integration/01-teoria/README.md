# Teoría — Implement Simple Lambda Function with SNS Integration

## Patrón fan-out: SNS → múltiples suscriptores

Un mismo mensaje publicado en un topic de SNS se entrega a **todos** sus suscriptores de forma independiente y en paralelo — en este lab, un email humano (notificación) y una cola SQS (para procesamiento programático posterior) reciben la misma notificación desde una sola llamada `sns:Publish`. Es el patrón estándar de "fan-out" para desacoplar un productor de múltiples consumidores con necesidades distintas (uno para alertar a una persona, otro para encolar trabajo).

## Confirmación de suscripción: email vs. SQS

Una suscripción por **email** queda en estado `PENDING_CONFIRMATION` hasta que el destinatario hace clic en el link de confirmación que SNS envía automáticamente — sin eso, SNS nunca entrega mensajes a ese endpoint. Una suscripción por **SQS**, en cambio, se confirma automáticamente al crearse (no hay "humano" que confirme) — pero requiere que la cola tenga una **queue policy** que autorice explícitamente a `sns.amazonaws.com` a hacer `sqs:SendMessage`, condicionada al topic de origen (`aws:SourceArn`) por seguridad — sin esa policy, SNS no tiene permiso para escribir en la cola aunque la suscripción exista.

## Formato del mensaje que SQS recibe desde SNS

Un mensaje que llega a una cola SQS vía una suscripción SNS no es el payload "crudo" que publicó el remitente — SNS lo envuelve en un sobre JSON con metadata (`Type`, `MessageId`, `TopicArn`, `Subject`, `Timestamp`, firma, `UnsubscribeURL`), y el contenido original queda anidado (como string) dentro del campo `Message`. Cualquier consumidor real de la cola necesita parsear ese sobre y extraer `Message` para llegar al payload de la aplicación.

## Llamar una API HTTP externa desde Lambda sin dependencias

Usar `urllib.request` (librería estándar de Python) para llamar la API pública de IPinfo evita tener que empaquetar dependencias externas (como `requests`) en el ZIP de despliegue o crear una Lambda Layer — para una llamada HTTP simple sin necesidad de manejo avanzado de sesiones/reintentos, la librería estándar es suficiente y mantiene el paquete de despliegue mínimo.

## IAM Role de Lambda: permisos de ejecución vs. permisos de negocio

`AWSLambdaBasicExecutionRole` (permisos para escribir logs en CloudWatch) y `AmazonSNSFullAccess` (permisos para publicar en SNS) son dos policies con propósitos distintos adjuntas al mismo rol — la primera es infraestructura mínima que **toda** función Lambda necesita para operar (sin ella, ni siquiera se puede depurar), la segunda es el permiso de negocio específico que esta función necesita para cumplir su tarea (publicar resultados).
