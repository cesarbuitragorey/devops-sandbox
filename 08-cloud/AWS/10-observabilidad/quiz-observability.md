# Quiz de DevOps Bootcamp — AWS Observability

Preguntas, respuestas correctas y explicaciones. Material de repaso para el módulo 10 (Observability) — CloudWatch, CloudTrail, EventBridge, Trusted Advisor.

---

### 1. Monitorear volúmenes EBS activos, snapshots activos e IPs elásticas para no exceder el límite de servicio. ¿Qué servicio ayuda?
- AWS Trusted Advisor
- AWS Detective
- AWS Inspector
- AWS CloudWatch

**Respuesta correcta:** AWS Trusted Advisor
**Por qué:** Trusted Advisor tiene un check de "Service Limits" que monitorea el uso contra las cuotas de servicio de AWS (incluyendo EBS, snapshots e IPs elásticas) y advierte al acercarse al límite. Detective es para investigación de seguridad (analizar logs para encontrar causas raíz); Inspector escanea vulnerabilidades de EC2/contenedores; CloudWatch monitorea métricas/logs pero no rastrea nativamente las cuotas de servicio de la cuenta como Trusted Advisor.

### 2. ¿Qué formatos soportan los schema registries dentro de EventBridge?
- JSONSchema Draft4
- OpenAPI 3
- YAML
- Python
- Go

**Respuesta correcta:** JSONSchema Draft4; OpenAPI 3
**Por qué:** El Schema Registry de EventBridge solo soporta JSONSchema Draft4 y OpenAPI 3 como formatos de especificación de esquema. YAML es un formato de serialización de datos, no un spec de esquema soportado aquí. Python y Go son lenguajes en los que EventBridge puede generar code bindings a partir de un esquema, pero no son formatos de definición de esquema en sí.

### 3. Notificación por email cuando CPU Utilization de una EC2 supera 80%. ¿Mejor método?
- Ninguno de estos es un método correcto
- Alarma de CloudWatch que dispare un "CloudWatch topic" para enviar el mensaje
- Alarma de billing que dispare cuando CPU supere 80%
- Alarma de CloudWatch que dispare un topic de SNS para enviar el mensaje

**Respuesta correcta:** Create a CloudWatch Alarm that will trigger when CPU Utilization goes above 80%, and have that alarm trigger an SNS topic to send you a message
**Por qué:** Una alarma de CloudWatch vigila la métrica CPUUtilization y, al superarse el umbral, publica en un topic de SNS que entrega el email. No existe un "CloudWatch topic" — esa opción confunde CloudWatch (métricas/alarmas) con SNS (entrega de notificaciones). Las alarmas de billing solo monitorean cargos estimados, no métricas de rendimiento como CPU.

### 4. ¿Dónde se almacenan los logs de CloudTrail?
- S3
- EFS
- DynamoDB
- RDS

**Respuesta correcta:** S3
**Por qué:** CloudTrail entrega los archivos de log a un bucket S3 especificado (también puede reenviar eventos a CloudWatch Logs). EFS/DynamoDB/RDS no tienen integración de entrega de CloudTrail.

### 5. ¿Qué dos formas permiten recolectar logs de CloudTrail de múltiples cuentas de AWS?
- Habilitar "Consolidated Security" en la consola de IAM
- Clic en "Apply Trail to Organization" al crear un nuevo Trail
- Crear un bucket S3 en una cuenta central, y configurar trails en cuentas hijas para enviar sus logs ahí
- Agregar todos los Account IDs conocidos en la sección de configuración multi-cuenta de la consola de CloudTrail

**Respuesta correcta:** Click the "Apply Trail to Organization" button when creating a new Trail; Create an S3 bucket in a central account, and configure trails in child accounts to send their logs there
**Por qué:** Con AWS Organizations, marcar "Apply trail to my organization" crea automáticamente el trail en cada cuenta miembro. Alternativamente, se pueden configurar trails manualmente en cada cuenta para entregar logs a un único bucket S3 central (con la bucket policy cross-account apropiada). No existe "Consolidated Security" en IAM ni una "sección de configuración multi-cuenta" para listar account IDs — ambas son inventadas.

### 6. ¿En cuáles de estos servicios se pueden habilitar "data events" detallados al configurar un trail en CloudTrail?
- Lambda
- S3
- EC2
- CloudWatch

**Respuesta correcta:** Lambda; S3
**Por qué:** Los Data Events de CloudTrail rastrean operaciones a nivel de plano de datos — soportados para S3 (actividad de API a nivel de objeto) y Lambda (invocaciones de función). Las acciones de EC2 se registran como management events, no data events. CloudWatch es un destino/servicio de monitoreo, no un tipo de recurso rastreado por data events.

### 7. ¿Para qué se puede usar el CloudWatch Agent?
- Para poder ver los logs que CloudWatch recolecta
- Para proteger adicionalmente el sistema de programas maliciosos y saber de su presencia
- Obtener información adicional de workloads recolectando métricas/logs específicos del SO y de aplicaciones; también recolectar, agregar y resumir métricas/logs de aplicaciones en contenedores y microservicios
- Para ser notificado cuando recursos como CPU/memoria se estén agotando

**Respuesta correcta:** Obtain additional information about workloads by collecting OS and application-specific metrics and logs. Also collect, aggregate and summarize metrics and logs from containerized applications and microservices
**Por qué:** El CloudWatch Agent se instala en instancias/servidores para recolectar métricas a nivel de SO (memoria, disco) y logs no recolectados por defecto, además de métricas/logs de workloads en contenedores. Ver logs se hace vía la consola/Logs Insights, no el agente. La protección contra malware describe una herramienta de seguridad como GuardDuty. Ser notificado sobre umbrales describe las CloudWatch Alarms, una feature separada.

### 8. ¿Es posible rastrear logs en tiempo real en el dashboard de CloudWatch?
- Yes
- No

**Respuesta correcta:** Yes
**Por qué:** CloudWatch Logs Live Tail transmite eventos de log coincidentes casi en tiempo real directamente desde la consola, permitiendo debugging en tiempo real en vez de esperar los delays de indexación estándar.

### 9. ¿Cómo recolectar métricas de memoria y espacio libre de instancias EC2?
- CloudWatch las recolecta por defecto
- Hay que instalar y configurar un CloudWatch agent en las instancias EC2 requeridas
- Hay que configurar un dashboard de CloudWatch para mostrar y recolectar esos datos
- Hay que crear una regla en CloudWatch Events

**Respuesta correcta:** Need to install and configure a CloudWatch agent on required EC2 instances
**Por qué:** Memoria y espacio libre en disco son métricas a nivel de SO, invisibles para el hipervisor, por lo que requieren el CloudWatch Agent instalado en la instancia. NO se recolectan por defecto (solo las visibles para el hipervisor, como CPU, red, I/O de disco). Los dashboards solo visualizan métricas existentes, no recolectan datos nuevos. CloudWatch Events (EventBridge) reacciona a cambios de estado, sin rol en la recolección de métricas.

### 10. ¿Cuál es la resolución de métrica más pequeña posible en CloudWatch?
- 1 second
- 30 seconds
- 1 minute
- 5 minutes

**Respuesta correcta:** 1 second
**Por qué:** CloudWatch soporta métricas custom de alta resolución publicadas con granularidad de 1 segundo. 30 segundos no es una opción de resolución válida. 1 minuto es la resolución estándar para la mayoría de métricas por defecto, pero no la más pequeña posible. 5 minutos era el intervalo antiguo por defecto de detailed monitoring, lejos de ser el más pequeño.

### 11. Como cloud administrator, ¿qué servicio recomendarías para entender protección de infraestructura y optimización de costos?
- AWS Inspector
- AWS Trusted Advisor
- AWS Config
- AWS WAF

**Respuesta correcta:** AWS Trusted Advisor
**Por qué:** Trusted Advisor escanea categorías incluyendo Seguridad (checks de protección de infraestructura) y Optimización de Costos (recursos inactivos, recomendaciones de RI) — cubriendo ambos pilares preguntados. Inspector es puramente escaneo de vulnerabilidades de seguridad sin dimensión de costo. AWS Config rastrea cambios de configuración/cumplimiento, no costo. AWS WAF solo protege la capa de aplicación de exploits web, sin relación con costos.

### 12. ¿Puede CloudWatch monitorear recursos fuera de AWS?
- Yes
- No

**Respuesta correcta:** Yes
**Por qué:** CloudWatch soporta monitoreo híbrido/on-premises vía el CloudWatch Agent instalado en cualquier servidor (on-prem u otra nube), que envía métricas/logs custom a CloudWatch igual que con EC2, siempre que pueda alcanzar el endpoint de CloudWatch con credenciales válidas.

### 13. ¿Por cuánto tiempo se pueden almacenar datos de log en el servicio de CloudWatch Logs?
- 1 month
- 2 years
- 5 years
- unlimited

**Respuesta correcta:** unlimited
**Por qué:** CloudWatch Logs soporta la configuración de retención "Never Expire", haciendo la duración de almacenamiento efectivamente ilimitada. 1 mes, 2 años y 5 años son solo opciones seleccionables de periodo de retención entre muchas — no el techo de cuánto se pueden conservar los logs.

### 14. ¿Qué es un schema dentro de EventBridge?
- Servicio de almacenamiento de replay de eventos
- Marketplace de eventos
- Un contenedor que define la estructura de eventos enviados a EventBridge
- Integración con DynamoDB que hospeda eventos históricos

**Respuesta correcta:** A container that defines the structure of events sent to EventBridge
**Por qué:** Un schema describe la estructura exacta del payload de un evento — un blueprint del JSON del evento — habilitando validación, documentación y generación automática de code bindings. El almacenamiento de replay de eventos describe la feature separada de Archive y Replay. No hay integración con DynamoDB detrás de los schemas — esa opción es inventada.

### 15. ¿Cómo se entiende qué es observability?
- Trabajar con buenas prácticas de AWS, haciendo la infraestructura altamente disponible y recuperable ante desastres
- Trabajar con buenas prácticas de AWS, haciendo la infraestructura altamente disponible, recuperable ante desastres y optimizada en costos
- Observability provee análisis y evaluación de la recolección de datos de infraestructura para optimización posterior
- Observability permite recolectar, correlacionar, agregar y analizar telemetría en los entornos de red, infraestructura y aplicaciones para obtener insights sobre el comportamiento, rendimiento y salud del sistema

**Respuesta correcta:** Observability lets you collect, correlate, aggregate, and analyze telemetry in your network, infrastructure, and applications environments so you can gain insights into the behavior, performance, and health of your system
**Por qué:** Esta captura correctamente observability: recolectar/correlacionar telemetría (logs, métricas, trazas) a través de los entornos para obtener insight sobre comportamiento, rendimiento y salud del sistema. Las primeras dos opciones describen los pilares de Reliability y Cost Optimization del AWS Well-Architected Framework, no observability en sí. La tercera es una definición incompleta, sin el concepto central de recolección de telemetría.

### 16. Si se necesita instalar el CloudWatch Agent en una AMI de Ubuntu, ¿dónde debe instalarse?
- Con instalarlo en una sola máquina es suficiente
- Hay que instalar el agente en cada servidor donde se aprovecharán sus funciones
- Con instalarlo en una sola máquina alcanza para cubrir todas las instancias de la región requerida
- El CloudWatch Agent se instala automáticamente al correr una instancia EC2, sin instalación adicional

**Respuesta correcta:** Need to install the agent on each server where you will make use of the opportunities the agent
**Por qué:** El CloudWatch Agent corre localmente en cada instancia individual que monitorea, leyendo métricas/logs locales del SO — debe instalarse en cada servidor del que se quieran datos detallados. No existe una feature de instalación única o cobertura a nivel de región, y el agente no se autoinstala en instancias EC2 nuevas — debe instalarse y configurarse manualmente.

### 17. Afirmaciones VERDADERAS sobre archivar y reproducir (replay) eventos en EventBridge
- El periodo de retención solo puede ser entre 1 y 30 días
- El periodo de retención solo puede ser entre 1 y 15 días
- Se pueden tener hasta 10 replays concurrentes a la vez
- AWS habilita cifrado por defecto de los datos archivados usando una CMK (customer managed key)
- Se especifica el tiempo de inicio y fin para el replay de eventos

**Respuesta correcta:** We can have a maximum of 10 concurrent replays going at once; We specify the start and end time for event replay
**Por qué:** EventBridge permite hasta 10 replays concurrentes por cuenta/región, y un replay requiere especificar una ventana `EventStartTime` y `EventEndTime`. La retención NO está limitada a 1-30 ni 1-15 días — se puede elegir cualquier duración o retención indefinida. La opción de cifrado es autocontradictoria: el default es una clave AWS-owned, no una customer managed key (una CMK es por definición una que tú gestionas).

### 18. Beneficios generales de CloudWatch
- Tomar acciones basadas en alarmas y triggers que se pueden crear
- CloudWatch provee cómputo serverless, corriendo tu código custom sin necesidad de una instancia EC2
- Provee insights de monitoreo sobre tus recursos de AWS
- Acceder a tus datos desde una sola plataforma

**Respuesta correcta:** Taking action based on alarms and triggers that can be created; It provides monitoring insights into your AWS resources; Access your data from a single platform
**Por qué:** Las CloudWatch Alarms disparan acciones basadas en umbrales; provee insight central de monitoreo sobre la salud/rendimiento de recursos AWS; y centraliza métricas, logs y eventos en una plataforma. La opción de cómputo serverless describe a AWS Lambda — CloudWatch no ejecuta código de aplicación custom.

### 19. Necesitas determinar si los roles IAM han cambiado en el último mes. ¿Cómo saber si hubo cambios?
- Usar AWS CloudTrail para ver si el rol IAM cambió
- Usar Amazon CloudWatch para ver si el security group cambió
- Usar AWS EventBridge para ver si el security group cambió
- Usar AWS Health para ver si el security group cambió

**Respuesta correcta:** Use AWS CloudTrail to see if the iam role was changed
**Por qué:** CloudTrail registra llamadas a la API incluyendo eventos de gestión de IAM (UpdateRole, AttachRolePolicy, etc.), y retiene 90 días de Event History por defecto, más que suficiente para un mes — permitiendo confirmar si/cuándo cambió un rol IAM. Las demás opciones referencian security groups (recurso equivocado) y describen herramientas de monitoreo/eventos en tiempo real/salud de servicio que no ofrecen búsqueda histórica de cambios de configuración.

### 20. Recolectar métricas estándar de CloudWatch para varias instancias EC2 cada 1 minuto. ¿Qué hacer?
- Habilitar CloudWatch Custom Metrics
- Habilitar High Resolution Metrics
- Habilitar Basic Monitoring
- Habilitar Detailed Monitoring

**Respuesta correcta:** Enable Detailed Monitoring
**Por qué:** Por defecto EC2 envía métricas estándar cada 5 minutos (Basic Monitoring). Habilitar Detailed Monitoring baja esto a intervalos de 1 minuto para métricas estándar. Custom Metrics es para datos que tú mismo envías, no métricas estándar de EC2. High Resolution Metrics aplica a métricas custom (sub-minuto), no a la frecuencia de métricas estándar de EC2. Basic Monitoring es el estado por defecto de 5 minutos — lo opuesto a lo necesario.

### 21. ¿Cuál de estos campos de evento NO se puede filtrar en la consola de CloudTrail?
- Event Name
- Resource Type
- Username
- AWS Account ID

**Respuesta correcta:** AWS Account ID
**Por qué:** Las opciones de filtro de Event History de CloudTrail incluyen Event name, User name, Event source, Resource name, Resource type, entre otros, pero AWS Account ID no es un atributo de filtro seleccionable (es implícito ya que estás viendo el trail de tu propia cuenta).

### 22. ¿Qué métricas de instancia NO se recolectan por defecto en CloudWatch?
- CPU utilization%
- MEMORY %
- DiskWriteBytes
- NetworkIn
- Todas las anteriores

**Respuesta correcta:** MEMORY %
**Por qué:** La utilización de memoria es una métrica a nivel de SO que requiere el CloudWatch Agent — es la única métrica de esta lista no recolectada por defecto. CPU utilization, DiskWriteBytes y NetworkIn son todas visibles a nivel de hipervisor y se recolectan automáticamente sin configuración adicional.

### 23. ¿Por cuánto tiempo puede CloudWatch conservar métricas de recursos eliminados?
- Se eliminan inmediatamente
- 5 minutos
- 5 días
- 15 semanas
- 15 meses

**Respuesta correcta:** 15 month
**Por qué:** CloudWatch retiene datos de métricas por 15 meses sin importar si el recurso subyacente fue eliminado, permitiendo ver datos históricos de rendimiento de recursos dados de baja bien más de un año después. Las demás duraciones no corresponden a la política de retención real de CloudWatch.

### 24. ¿Están habilitados por defecto los Data Events (logging avanzado de S3 y Lambda) en CloudTrail?
- No
- Yes

**Respuesta correcta:** No
**Por qué:** Los Data Events están apagados por defecto porque pueden generar volúmenes de log muy altos y costo. Solo los Management Events se registran por defecto al crear un trail; los Data Events deben habilitarse explícitamente y configurarse en recursos específicos.

### 25. Arquitectura serverless con SNS, Lambda y EventBridge, un solo event bus custom, ~340 reglas estimadas. ¿Es posible este diseño?
- No. Solo se pueden tener 300 reglas por event bus
- Sí. Se pueden tener hasta 400 reglas por un solo event bus
- No. Solo se pueden tener 200 reglas por event bus
- Sí. Puede haber 350 reglas para un solo event bus

**Respuesta correcta:** Yes. You can have up to 400 rules per a single event bus
**Por qué:** La cuota soft por defecto es 300 reglas por event bus, pero es ajustable vía una solicitud de aumento de cuota de servicio, hasta un máximo documentado de 400 reglas por event bus. Como 340 reglas cae dentro de ese techo ampliado, el diseño es alcanzable una vez solicitado el aumento de cuota. Las cifras de 200 y 350 no corresponden a cuotas reales de EventBridge.
