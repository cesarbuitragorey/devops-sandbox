# Quiz de DevOps Bootcamp — AWS Serverless

Preguntas, respuestas correctas y explicaciones. Material de repaso para el módulo 9 (AWS Serverless) — Lambda, SNS, SQS, API Gateway.

---

### 1. Amazon SQS puede verse como una clase de almacenamiento de datos __________ para muchas clases de aplicaciones.
- Temporary
- Semipermanent
- Transitional

**Respuesta correcta:** Temporary
**Por qué:** SQS almacena mensajes de forma temporal — permanecen en la cola hasta ser consumidos y eliminados, o hasta que expira el periodo de retención (4 días por defecto, configurable hasta 14 días). No es almacenamiento permanente de datos.

### 2. El pricing de Amazon SQS se basa en el número de __________ y la cantidad de __________ transferida entrando y saliendo.
- Requests/data
- Calls/messages
- Downloads/permits

**Respuesta correcta:** Requests/data
**Por qué:** Se basa en el número de requests (SendMessage, ReceiveMessage, DeleteMessage, etc.) y en la cantidad de data transfer, con una capa gratuita mensual de requests.

### 3. App donde usuarios se suscriben por email para recibir mensajes publicados. ¿Qué servicio usar?
- AWS SNS
- AWS Config
- AWS S3
- AWS Glacier

**Respuesta correcta:** AWS SNS
**Por qué:** SNS es un servicio pub/sub que permite suscripción por email (entre otros protocolos); al publicar un mensaje, SNS lo distribuye automáticamente a todos los suscriptores.

### 4. Construir y desplegar funciones de código sin gestionar infraestructura. ¿Qué servicio?
- AWS Lambda
- AWS EC2
- AWS API Gateway
- AWS DynamoDB

**Respuesta correcta:** AWS Lambda
**Por qué:** Lambda es cómputo serverless — AWS gestiona toda la infraestructura subyacente, solo se paga por el tiempo de cómputo consumido. EC2 requiere gestionar el SO; API Gateway no ejecuta código por sí solo; DynamoDB es una base de datos.

### 5. SQS fue diseñado para permitir un número __________ de servicios de mensajería leer/escribir un número __________ de mensajes.
- Unlimited/unlimited
- Unlimited/limited
- Limited/unlimited
- Limited/limited

**Respuesta correcta:** Unlimited/unlimited
**Por qué:** SQS está diseñado para escalar de forma prácticamente ilimitada en ambas dimensiones, sin límites artificiales de escala.

### 6. API con 1000 req/s, se busca hosting costo-efectivo. ¿Mejor solución?
- API Gateway + AWS Lambda
- API Gateway con el backend tal cual está
- CloudFront + el backend tal cual está
- ElastiCache + el backend tal cual está

**Respuesta correcta:** Use the API Gateway along with AWS Lambda
**Por qué:** API Gateway + Lambda es una arquitectura serverless completamente administrada, con pago por uso y escalado automático — la opción más costo-efectiva. Las demás opciones no cambian el backend tradicional subyacente ni resuelven el problema de gestión de infraestructura.

### 7. Para evitar pérdida de mensajes, SQS los almacena __________ en múltiples servidores y centros de datos.
- Redundantly
- Publicly
- Superfluously
- Privately

**Respuesta correcta:** Redundantly
**Por qué:** SQS almacena todos los mensajes de forma redundante (múltiples copias) en varios servidores/centros de datos de una región, garantizando alta disponibilidad y durabilidad.

### 8. Servicio de suscripción con notificaciones sobre nuevas actualizaciones. ¿Qué usar?
- SNS Service
- SQS Service
- EC2 + Rabbit-MQ
- AWS DynamoDB streams

**Respuesta correcta:** Use the SNS Service to send the notification
**Por qué:** SNS es el servicio pub/sub diseñado exactamente para este caso — suscripción a un tópico + notificación automática al publicar, vía múltiples protocolos. SQS es punto a punto, no pub/sub; DynamoDB Streams captura cambios de tabla, no suscripciones de usuarios.

### 9. Monitorear ReadIOPS/WriteIOPS de RDS MySQL y alertar en tiempo real al equipo de Operaciones (2 puntos)
- Amazon CloudWatch
- Amazon Simple Notification Service
- Amazon Simple Email Service
- Amazon Simple Queue Service

**Respuesta correcta:** Amazon CloudWatch; Amazon Simple Notification Service
**Por qué:** CloudWatch recopila métricas de RDS y permite crear alarmas; SNS se integra con esas alarmas para notificar en tiempo real. SES es para correo masivo/transaccional (no monitoreo); SQS es de colas, no de alertas a humanos.

### 10. Funciones Lambda con lógica de negocio; clientes deben poder invocarlas vía HTTPS. ¿Cómo lograrlo?
- API Gateway con integración a Lambda
- Habilitar acceso HTTP en las funciones Lambda
- EC2 con servidor API integrado a Lambda, expuesto vía sitios web S3
- Usar sitios web S3 para llamar a Lambda

**Respuesta correcta:** Use the API Gateway and provide integration with the AWS Lambda functions
**Por qué:** API Gateway está diseñado específicamente para exponer Lambda como endpoints HTTPS (Lambda proxy integration) — arquitectura estándar y totalmente administrada. Lambda no tiene "habilitar HTTP" nativo; EC2 y S3 no son soluciones apropiadas.

### 11. Construir una app nueva con arquitectura de microservicios en AWS. Elegir 3
- AWS Lambda
- AWS ECS
- AWS API Gateway
- AWS Config

**Respuesta correcta:** AWS Lambda; AWS ECS; AWS API Gateway
**Por qué:** Lambda ejecuta cada microservicio como función independiente; ECS como contenedor independiente; API Gateway actúa como puerta de entrada única. AWS Config es de auditoría/cumplimiento, sin relación con construir/exponer microservicios.

### 12. Feature de SQS que permite fijar un retraso antes de que un mensaje esté disponible para consumidores
- Delayed Queue
- Message Timer
- Visibility Delay
- Message Scheduler

**Respuesta correcta:** Delayed Queue
**Por qué:** Las Delay Queues retrasan la entrega de nuevos mensajes (0-900 segundos / 15 min configurable). "Visibility Delay" mezcla incorrectamente el concepto de Visibility Timeout (retraso tras ser recibido por un consumidor), que es un mecanismo distinto.

### 13. Página de registro a eventos; enviar SMS cada vez que alguien se registra. ¿Qué servicio administrado usar?
- Amazon SNS
- Amazon STS
- Amazon SQS
- AWS Lambda

**Respuesta correcta:** Amazon SNS
**Por qué:** SNS puede enviar SMS directamente a usuarios publicando un mensaje en un tópico. STS genera credenciales temporales (sin relación); SQS es de colas, no envía SMS directamente; Lambda podría disparar el envío pero no es el servicio de mensajería en sí.

### 14. App stateless que debe escalar según demanda. ¿Servicio de cómputo ideal?
- AWS Lambda
- AWS DynamoDB
- AWS S3
- AWS SQS

**Respuesta correcta:** AWS Lambda
**Por qué:** Lambda es intrínsecamente stateless (cada invocación es independiente) y escala automáticamente según demanda. DynamoDB/S3/SQS no son servicios de cómputo — no ejecutan la lógica de la aplicación.

### 15. SQS está optimizado para escalabilidad __________, no para velocidad de envío/recepción de un solo hilo.
- Horizontal
- Lateral
- Parallel
- Frontal
- Vertical

**Respuesta correcta:** Horizontal
**Por qué:** SQS está optimizado para escalado horizontal (más consumidores/productores en paralelo), no vertical (aumentar la capacidad de un solo nodo, justo lo opuesto a la prioridad de diseño de SQS).

### 16. Jobs de administración en C# migrando a AWS. ¿Forma eficiente de hospedarlos?
- AWS Lambda functions con C#
- AWS DynamoDB para guardar los jobs y correrlos on-demand
- AWS S3 para guardar los jobs y correrlos on-demand
- AWS Config functions con C#

**Respuesta correcta:** Use AWS Lambda functions with C# for the Admin jobs
**Por qué:** Lambda soporta C# (.NET) nativamente como runtime oficial, permitiendo migrar los jobs sin reescribirlos, ejecutándolos bajo demanda sin gestionar servidores. DynamoDB/S3 no ejecutan código; AWS Config no tiene funciones de cómputo personalizadas.

### 17. Guardar el nombre de cada archivo subido a S3 en una tabla DynamoDB (2 puntos: cada respuesta es parte de la solución)
- Crear una función Lambda que inserte el registro por cada archivo subido
- Agregar un evento con notificación enviada a Lambda
- Usar CloudWatch para sondear cualquier evento de S3
- Agregar el evento de CloudWatch a la sección de streams de la tabla DynamoDB
- Usar una feature nativa de S3 para nombres de archivo por trigger de evento

**Respuesta correcta:** Create an AWS Lambda function to insert the required entry for each uploaded file; Add an event with notification send to Lambda
**Por qué:** La arquitectura correcta es: notificación de evento S3 (ej. `s3:ObjectCreated:*`) → invoca Lambda → Lambda hace `PutItem` en DynamoDB. CloudWatch no "sondea" eventos de S3 (la integración nativa es notificación de eventos, no polling); DynamoDB Streams captura cambios dentro de la tabla, no es un lugar para "agregar" eventos S3; S3 no tiene una feature nativa que escriba directamente en DynamoDB sin un intermediario de cómputo.
