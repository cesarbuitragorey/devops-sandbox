# Quiz de DevOps Bootcamp — AWS Certification Final (57 preguntas)

Preguntas, respuestas correctas y explicaciones. Quiz final de repaso general — cubre todos los módulos del bootcamp (EC2, S3, IAM, VPC, RDS, EFS, ECS/EKS, Lambda, API Gateway, CloudFormation, CloudWatch/CloudTrail/EventBridge, seguridad).

---

### 1. ¿Está disponible la opción Spot para Fargate?
- No, las instancias Spot son una característica exclusiva de EC2
- Sí, con la funcionalidad de capacity provider se pueden correr tareas en Spot

**Respuesta correcta:** Yes, with capacity provider functionality you can run your tasks on spot.
**Por qué:** ECS (y EKS) permite usar Fargate Spot mediante capacity providers (FARGATE_SPOT), ejecutando tareas en capacidad Spot con hasta 70% de descuento. La otra opción es falsa: Spot se extendió más allá de EC2 gracias a los capacity providers.

### 2. Quieres desplegar tu propia AMI personalizada en los nodos de un cluster EKS. ¿Qué opción eliges?
- Crear el cluster EKS usando managed node groups
- Crear el cluster EKS usando self managed nodes
- Crear el cluster EKS usando AWS Fargate
- No se puede desplegar una AMI personalizada en los nodos del cluster
- Deberías pedirle a AWS Support que despliegue tu AMI personalizada en los nodos

**Respuesta correcta:** Create EKS cluster using Self managed nodes
**Por qué:** Con self-managed nodes tú provisionas las EC2 con tu propio AMI vía Auto Scaling Group. Managed node groups usan AMIs optimizadas de EKS (control limitado); Fargate no usa AMIs; las otras dos opciones son falsas.

### 3. Un sitio web estático hospedado en S3 devuelve 403 (Forbidden). ¿Cuál es la posible causa?
- Falta de permisos requeridos en la política de IAM
- El cifrado del bucket está habilitado
- La bucket policy no permite lecturas públicas
- El bucket está en otra región

**Respuesta correcta:** Bucket policy doesn't allow public reads
**Por qué:** Se necesita una bucket policy que permita s3:GetObject públicamente. IAM aplica a identidades autenticadas, no visitantes anónimos; encriptación no bloquea acceso HTTP; la región no causa 403.

### 4. Elige los modos de configuración soportados para instancias burstable (2 opciones)
- Standard
- Unlimited
- Restricted
- Unrestricted
- Intelligent

**Respuesta correcta:** Standart; Unlimited
**Por qué:** Las instancias T soportan modo Standard (limita a créditos acumulados) y Unlimited (sostiene rendimiento alto con cargo extra). Restricted/Unrestricted/Inteligent son distractores inventados.

### 5. ¿Qué es un componente de Amazon ECR?
- Registry
- Authorization token
- Repository
- Repository policy
- Image
- Todos los mencionados
- Ninguno de los mencionados

**Respuesta correcta:** All of mentioned points
**Por qué:** Registry, authorization token, repository, repository policy e image son todos componentes reales de ECR, por eso la respuesta correcta es "All of mentioned points".

### 6. Tienes funciones Lambda con lógica de negocio. Quieres que los clientes las invoquen vía HTTPS. ¿Cómo lograrlo?
- Habilitar acceso HTTP en las funciones Lambda
- Usar API Gateway e integrarlo con las funciones Lambda
- Agregar instancias EC2 con un servidor API instalado, integrarlas con Lambda, y usar sitios web S3 para llamar a Lambda
- Usar sitios web S3 para llamar a las funciones Lambda

**Respuesta correcta:** Use the API Gateway and provide integration with the AWS Lambda functions
**Por qué:** API Gateway está diseñado para exponer Lambda como endpoints HTTPS/REST, gestionando auth, throttling y transformación de payloads. Lambda no tiene "acceso HTTP" nativo; las demás opciones son innecesariamente complejas o no funcionan de forma directa.

### 7. VPC Flow Logs muestran Inbound ACCEPT y Outbound REJECT para la misma IP. ¿Qué revisar primero?
- Revisar la NACL
- Revisar el Security Group
- Revisar la tabla de rutas
- Revisar la configuración del ENI
- Conectarse por SSH a la EC2 y revisar la configuración de red
- Revisar las reglas de AWS WAF

**Respuesta correcta:** Check the NACL
**Por qué:** Este patrón (accept/reject asimétrico) es típico de NACLs, que son stateless. Los SG son stateful y no generarían este comportamiento; las demás opciones no explican el patrón descrito.

### 8. Una compañía con Admin jobs en C# migra a AWS. ¿Cuál es la forma eficiente de hospedarlos?
- Usar DynamoDB para almacenar los jobs y correrlos on demand
- Usar funciones Lambda con C# para los Admin jobs
- Usar S3 para almacenar los jobs y correrlos on demand
- Usar funciones de AWS Config con C# para los Admin jobs

**Respuesta correcta:** Use AWS Lambda functions with C# for the Admin jobs.
**Por qué:** Lambda soporta C# (.NET) nativamente, permitiendo migrar los jobs sin reescribirlos, de forma serverless. DynamoDB y S3 son almacenamiento, no cómputo; AWS Config es para auditoría de configuración.

### 9. ¿Qué entidad NO puede ser un principal?
- Role
- Group
- AWS services
- User

**Respuesta correcta:** Group
**Por qué:** Un group es solo una colección organizativa de usuarios, no una identidad; no puede ser principal. Role, AWS services y User sí pueden actuar como principals.

### 10. ¿Qué feature de IAM permite autenticar usuarios con Facebook, Google o Amazon?
- La API HTTPS de IAM
- Web Identity Federation
- Multi-Factor Authentication
- AWS Single Sign-On (SSO)

**Respuesta correcta:** Web Identity Federation
**Por qué:** Web Identity Federation permite autenticación con proveedores OIDC (Facebook, Google, Amazon), obteniendo credenciales temporales vía STS, típicamente con Cognito. MFA es un segundo factor; SSO gestiona acceso empresarial centralizado.

### 11. ¿Cuáles de las siguientes afirmaciones sobre EFS son VERDADERAS? (5 opciones)
- NFS administrado que se puede montar en varias EC2 pero solo en una AZ
- EFS está disponible para instancias EC2 en múltiples AZ
- Compatible con Linux y Windows
- EFS crece y se reduce automáticamente al agregar/quitar archivos
- Los security groups deben usarse para controlar el tráfico NFS
- EFS es más costoso que EBS
- Necesitas elegir el plan de capacidad antes de aprovisionar almacenamiento
- EFS soporta cifrado en reposo y en tránsito usando KMS

**Respuesta correcta:** EFS is available for EC2 instances within multiple AZ; EFS automatically grows and shrinks as you add and remove files; Security groups should be used to control NFS traffic; EFS is more expensive then EBS; EFS Supports encryption at rest and in transit using KMS
**Por qué:** EFS es multi-AZ, elástico automáticamente, controlado por security groups, más costoso que EBS por GB, y soporta cifrado con KMS. Es solo compatible con Linux (no Windows), no está limitado a una AZ, y no requiere planificar capacidad (a diferencia de EBS).

### 12. ¿Cuál de las siguientes NO es una opción de S3 Storage Class?
- S3 Standard
- S3 Intelligent-Tiering
- S3 Standard-IA
- S3 One Zone-IA
- S3 Glacier
- S3 Glacier Deep Archive
- S3 Outposts
- S3 Regional-IA

**Respuesta correcta:** S3 Regional-IA
**Por qué:** "S3 Regional-IA" no existe; es un distractor. Todas las demás son clases reales de almacenamiento en S3.

### 13. Aplicación EC2 + RDS. ¿Cómo asegurar alta disponibilidad de la capa de base de datos?
- Crear otra EC2 en otra AZ y hospedar una réplica de la base de datos
- Crear otra EC2 en otra AZ y hospedar una réplica del servidor web
- Habilitar Read Replica para la base de datos RDS
- Habilitar Multi-AZ para la base de datos RDS

**Respuesta correcta:** Enable Multi-AZ for the AWS RDS database.
**Por qué:** Multi-AZ crea una standby síncrona con failover automático, garantizando HA de la base de datos. Read Replicas son para escalar lecturas, sin failover automático; las opciones EC2 manual son ineficientes y no nativas.

### 14. ¿Cuáles son las afirmaciones VERDADERAS sobre Security Groups?
- Los SG controlan cómo se permite el tráfico de entrada/salida hacia instancias EC2
- Los SG contienen reglas de allow y deny
- Las reglas de los SG pueden referenciar por IP o por security group
- Los SG son stateless
- Los SG gestionan el acceso a puertos
- No se pueden asociar a múltiples instancias
- Están atados a una región
- Todo el tráfico inbound y outbound está bloqueado por defecto

**Respuesta correcta:** Security Group controls how traffic is allowed into or out of EC2 Instances; Security Groups rules can reference by IP or by security group; Security Groups manages access to ports; Locked down to a region
**Por qué:** Los SG controlan tráfico in/out, referencian por IP o SG, gestionan puertos, y están atados a una región (vía VPC). Solo soportan reglas allow (no deny), son stateful (no stateless), pueden asociarse a múltiples instancias, y por defecto bloquean inbound pero permiten todo outbound.

### 15. Load testing en RDS MySQL, 100% CPU, app read-heavy. ¿Qué métodos ayudan a escalar la capa de datos? (3 opciones)
- Agregar Read Replicas de RDS y dirigir las consultas de lectura hacia ellas
- Agregar la instancia RDS a un Auto Scaling Group y configurar una métrica de CloudWatch basada en CPU
- Hacer sharding de los datos entre varias instancias RDS
- Usar ElastiCache delante de RDS para cachear consultas comunes

**Respuesta correcta:** Add Amazon RDS DB Read Replicas, and have your application direct read queries to them; Shard your data set among multiple Amazon RDS DB Instances; Use ElastiCache in front of your Amazon RDS DB to cache common queries
**Por qué:** Read Replicas, sharding y ElastiCache reducen la carga de CPU en RDS. RDS no soporta Auto Scaling Groups de cómputo (eso es de EC2); RDS solo tiene Storage Auto Scaling.

### 16. Quieres escalar un ASG basado en requests/minuto que la app envía a una base de datos standalone. ¿Qué hacer?
- Crear una métrica personalizada de CloudWatch y luego una alarma sobre esa métrica para escalar el ASG
- Es imposible hacer esto
- Habilitar Detailed Monitoring y luego crear una alarma de CloudWatch para escalar el ASG
- Pedirle a AWS Support que cree esta métrica y escale tu ASG con ella

**Respuesta correcta:** Create a CloudWatch custom metric then create a CloudWatch alarm on this metric to scale ASG
**Por qué:** Se necesita publicar una métrica personalizada en CloudWatch y crear una alarma sobre ella. Detailed Monitoring solo aumenta la frecuencia de métricas estándar, no crea esta métrica; no se requiere AWS Support.

### 17. Restringir tráfico a nivel de pod y asignar distintos security groups a pods individuales. ¿Es posible?
- Sí, si usas nodos managed de EKS con Linux
- Sí, si usas nodos self managed con Linux y Windows
- Sí, si usas AWS Fargate
- No, no se pueden asignar distintos security groups a pods individuales
- No, no puedes hacerlo tú mismo, deberías pedirle a AWS Support que lo haga

**Respuesta correcta:** Yes, if you use EKS managed node with Linux OS; Yes, if you use AWS Fargate
**Por qué:** "Security Groups for Pods" funciona en nodos EKS Linux (managed o self-managed) y en Fargate, vía branch ENIs del VPC CNI plugin. No es compatible con Windows; sí es posible sin intervención de AWS Support.

### 18. RDS como plataforma de DB administrada. ¿Qué feature NO soporta RDS?
- Backup automático
- Escalado automático para manejar mayor carga
- Detección y recuperación automática de fallos
- Parcheo automático de software

**Respuesta correcta:** Automated scaling to manage a higher load
**Por qué:** RDS no ofrece auto-scaling de cómputo/CPU nativo (solo Storage Auto Scaling). Sí soporta backups automáticos, failover con Multi-AZ, y parcheo automático de software.

### 19. Eres el bucket owner y otorgas permisos cross-account a Bob para subir objetos. ¿Qué es verdadero?
- Bob será el owner de los objetos que suba
- No tendrás permisos sobre los objetos subidos por Bob
- Bob pagará la factura de todos los objetos nuevos que suba
- Puedes denegar acceso a cualquier objeto, sin importar quién lo suba
- No puedes borrar los objetos subidos por Bob

**Respuesta correcta:** Bob will be an owner of those objects that he uploaded; You will not have permissions on the objects that were uploaded by Bob; You can deny access to any objects, regardless of who uploads them; You cannot delete those objects that were uploaded by Bob
**Por qué:** En S3, el que sube el objeto es el owner por defecto; el bucket owner no tiene permisos automáticos sobre esos objetos ni puede borrarlos, pero sí puede denegar acceso vía bucket policy. Sin embargo, el bucket owner es quien paga el almacenamiento, no Bob.

### 20. Elige las afirmaciones VERDADERAS sobre un bucket de Amazon S3 (4 opciones)
- Los buckets deben tener un nombre único globalmente
- Los buckets se definen a nivel de AZ
- El nombre del bucket puede tener hasta 63 caracteres
- El nombre del bucket puede empezar con mayúscula o número
- No se permite guion bajo en el nombre del bucket
- Los buckets de S3 son específicos de una región
- Puedes usar una dirección IP como nombre de bucket

**Respuesta correcta:** Buckets must have a globally unique name; The name of the bucket must be up to 63 characters long; No underscore in the name of bucket; S3 buckets are region specific
**Por qué:** Los nombres de bucket son únicos globalmente, hasta 63 caracteres, sin guion bajo; los buckets son específicos de una región. No se definen a nivel de AZ, no pueden empezar con mayúscula, y no pueden tener formato de IP.

### 21. Correr una app en un ASG que escala instancias EC2 hacia adentro/afuera se llama...
- Horizontal Scalability
- Vertical Scalability

**Respuesta correcta:** Horizontal Scalability
**Por qué:** Horizontal scaling agrega/quita instancias (lo que hace un ASG). Vertical scaling cambia el tamaño de una sola instancia.

### 22. ¿Cuál es la menor resolución de métrica en CloudWatch?
- 1 segundo
- 30 segundos
- 1 minuto
- 5 minutos

**Respuesta correcta:** 1 second
**Por qué:** CloudWatch soporta métricas de alta resolución de hasta 1 segundo mediante StorageResolution=1. 1 minuto es la resolución estándar; 5 minutos es la básica de algunos servicios.

### 23. myapp.com en Route 53 debe apuntar al ELB myapp-elb-...elb.amazonaws.com. ¿Qué tipo de registro usar?
- CNAME
- Alias
- TXT record
- A record

**Respuesta correcta:** Alias
**Por qué:** Alias permite mapear el dominio raíz/TLD hacia recursos AWS (como un ELB), sin costo extra. CNAME está prohibido en el apex del dominio; TXT es para texto arbitrario; A record usaría IPs fijas, poco práctico para un ELB.

### 24. ¿Qué formatos soportan los schema registries dentro de EventBridge?
- JSONSchema Draft4
- OpenAPI 3
- YAML
- Python
- Go

**Respuesta correcta:** JSONSchema Draft4; OpenAPI 3
**Por qué:** Los schema registries de EventBridge usan JSONSchema Draft4 y OpenAPI 3. Python y Go son lenguajes hacia los que se generan bindings de código, no formatos de esquema; YAML no está soportado.

### 25. Quieres construir y desplegar funciones de código en AWS sin gestionar infraestructura. ¿Qué servicio?
- AWS EC2
- AWS API Gateway
- AWS Lambda
- AWS DynamoDB

**Respuesta correcta:** AWS Lambda
**Por qué:** Lambda es el servicio serverless diseñado exactamente para esto. EC2 requiere gestión manual; API Gateway expone APIs (no ejecuta lógica); DynamoDB es una base de datos.

### 26. ¿Cuáles afirmaciones son VERDADERAS sobre AWS PrivateLink? (3 opciones)
- Es la forma más segura y escalable de exponer un servicio a miles de VPC
- Requiere VPC Peering
- No requiere Internet Gateway, NAT, ni tablas de rutas
- Requiere un Network Load Balancer (VPC del servicio) y un VPC Endpoint

**Respuesta correcta:** Most secure and scalable way to expose a service to 1000s of VPC; Doesn't require Internet Gateway, NAT, route tables; Require Network Load Balancer (Service VPC) and VPC Endpoint
**Por qué:** PrivateLink expone servicios de forma segura y escalable a miles de VPCs, sin IGW/NAT/route tables, usando NLB (lado del proveedor) y VPC Endpoint (lado del consumidor). No requiere VPC Peering — de hecho, lo elimina.

### 27. ¿Cómo agregar una policy de IAM que dé acceso de solo lectura a S3 (a partir de una policy con ListAllMyBuckets)?
- Reemplazar la acción `s3:ListAllMyBuckets` por `s3:GetObject`
- Agregar un nuevo statement con la acción `s3:GetObject` y el resource `arn:aws:s3:::*`
- Agregar un nuevo statement con la acción `s3:GetObject` y el resource `arn:aws:s3:::bucket-name/*`
- Reemplazar la acción `s3:ListAllMyBuckets` por `s3:GetBucket`

**Respuesta correcta:** Add a new statement with the `s3:GetObject` action and `arn:aws:s3:::bucket-name/*` resource.
**Por qué:** Se debe añadir un nuevo statement con s3:GetObject y el resource bucket-name/* (formato correcto para objetos). Reemplazar ListAllMyBuckets eliminaría la función de listar buckets; el resource arn:aws:s3:::* sin /* no es el patrón correcto para GetObject; s3:GetBucket no es una acción válida.

### 28. Un usuario IAM requiere acceso a la consola y MFA obligatorio en cada login. ¿Qué permisos mínimos se requieren?
- Las acciones `iam:CreateLoginProfile` y `iam:AddUserToGroup`
- Las acciones `iam:CreateMFADevice` y `iam:PassRole`
- Las acciones `iam:RequireMFADevice` y `iam:PutUserPolicy`
- Las acciones `iam:CreateLoginProfile` y `iam:CreateVirtualMFADevice`

**Respuesta correcta:** The `iam:CreateLoginProfile` action and `iam:CreateVirtualMFADevice` action.
**Por qué:** Se necesita CreateLoginProfile (para el acceso a consola) y CreateVirtualMFADevice (para crear el dispositivo MFA). Las demás opciones usan acciones inválidas o no relacionadas con MFA.

### 29. Los VPC Endpoints permiten...
- Conectarte a servicios de AWS usando una red privada en vez de internet público
- Conectar tu datacenter on-premise a recursos de AWS
- Conectar tus VPCs de forma transitiva
- Conectar VPCs entre distintas cuentas

**Respuesta correcta:** To connect to AWS services using a private network instead of using the public internet
**Por qué:** VPC Endpoints conectan tu VPC de forma privada a servicios AWS sin pasar por internet. Conectar on-premise es función de Direct Connect/VPN; conectar VPCs transitivamente es Transit Gateway; conectar VPCs entre cuentas es VPC Peering.

### 30. ¿Cuáles son las afirmaciones VERDADERAS sobre block storage? (2 opciones)
- Los datos se almacenan en volúmenes y bloques... cada bloque tiene su propia dirección y metadata
- Se puede acceder a los datos directamente vía APIs o http/https
- Los datos se almacenan en volúmenes y bloques... cada bloque tiene dirección pero no tiene metadata
- El acceso a los datos está restringido a una única ruta
- En block storage los datos se almacenan en archivos... jerarquía de directorios y subdirectorios
- Block storage ofrece mayor eficiencia de almacenamiento y mejor rendimiento que file storage
- En block storage no hay carpetas ni directorios... un número de ID único

**Respuesta correcta:** Data is stored in volumes and blocks... Each block has its own address and don't have metadata; Block storage offers greater storage efficiency and faster performance than file storage
**Por qué:** En block storage, cada bloque tiene dirección pero NO metadata (a diferencia de object storage), y ofrece mayor eficiencia/rendimiento que file storage. Las demás opciones describen file storage o object storage, no block storage.

### 31. ¿Cuáles son características de CloudFormation?
- Las plantillas se pueden subir a S3 y luego referenciarse en CloudFormation
- Para actualizar una plantilla, se puede editar la existente en la consola de AWS, sin tener que resubir una nueva versión
- Los stacks se identifican por un nombre
- Borrar un stack no borra todos los recursos creados por CloudFormation, hay que hacerlo manualmente

**Respuesta correcta:** Templates could be uploaded to S3 and then referenced in CloudFormation; Stacks are identified by a name; Deleting a stack doesn't delete every resource that was created by CloudFormation, you have to do this manually
**Por qué:** Las plantillas pueden subirse a S3 y referenciarse, los stacks se identifican por nombre, y borrar un stack no siempre elimina todos los recursos (algunos requieren eliminación manual). Actualizar un stack siempre requiere una nueva versión de la plantilla.

### 32. Tienes un Key Pair de EC2 para SSH. Una vez dentro, ¿cómo obtienes el Instance ID?
- Crear un rol IAM y adjuntarlo a la instancia para poder hacer la llamada describe-instances
- Consultar el user data en https://169.254.169.254/latest/user-data
- Consultar el metadata en http://169.254.169.254/latest/metadata
- Obtener el Instance ID de su sistema de archivos local en /etc/aws/instance_id

**Respuesta correcta:** Query the metadata at http://169.254.169.254/latest/metadata
**Por qué:** El Instance Metadata Service en 169.254.169.254/latest/meta-data/ provee el instance-id directamente, sin permisos IAM adicionales. User-data contiene el script de inicialización, no metadata; la ruta local mencionada no es estándar; IAM Role + API call es innecesariamente complejo.

### 33. ¿Cuáles son características de una Read Replica? (4 opciones)
- Puede servir tráfico legítimo
- No puede usarse para disaster recovery
- Es útil para disaster recovery
- Recibe el trabajo descargado de la base de datos master
- No se puede promover a instancia standalone
- No puede servir tráfico legítimo
- Puede promoverse a una instancia de base de datos standalone

**Respuesta correcta:** Can serve legitimate traffic; Helpful with disaster recovery; Receives the offloaded work of master database; Can be promoted to a stand-alone database instance
**Por qué:** Las Read Replicas sirven tráfico real, ayudan en disaster recovery, descargan trabajo del master, y pueden promoverse a instancias standalone. Las opciones que niegan estas capacidades son falsas.

### 34. ¿Los Data Events (logging avanzado de S3 y Lambda) están habilitados por defecto en CloudTrail?
- No
- Sí

**Respuesta correcta:** No
**Por qué:** Los Data Events deben habilitarse manualmente debido a su alto volumen y costo asociado; los Management Events sí vienen habilitados por defecto.

### 35. ¿Por cuánto tiempo puedes contratar una EC2 Reserved Instance?
- 1 o 3 años
- Hasta 1 año
- Cualquier plazo entre 1 y 3 años
- 1 mes o 3 meses
- 2 o 4 años

**Respuesta correcta:** 1 or 3 years
**Por qué:** Las Reserved Instances se contratan con términos fijos de exactamente 1 o 3 años, no plazos intermedios ni otros períodos.

### 36. ¿Cuál de las siguientes NO es una funcionalidad de IAM?
- Federación de identidad para acceso delegado a la consola de AWS o las APIs
- Control de acceso granular a recursos de AWS
- Control centralizado de tu cuenta de AWS
- Autenticación biométrica, para que no se requieran contraseñas

**Respuesta correcta:** Biometric authentication, so that no passwords are required
**Por qué:** IAM no ofrece autenticación biométrica nativa. Sí ofrece federación de identidad, control de acceso granular y control centralizado de la cuenta.

### 37. Una app sube archivos a S3. Quieres que el nombre del archivo se guarde en DynamoDB (2 partes de la solución)
- Crear una función Lambda que inserte el registro requerido por cada archivo subido
- Usar CloudWatch para sondear cualquier evento de S3
- Agregar un evento con notificación enviada a Lambda
- Agregar el evento de CloudWatch a la sección de streams de la tabla DynamoDB
- Usar la funcionalidad nativa de S3 para nombrar archivos subidos por evento

**Respuesta correcta:** Create an AWS Lambda function to insert the required entry for each uploaded file.; Add an event with notification send to Lambda.
**Por qué:** Se necesita una función Lambda que inserte el registro en DynamoDB, disparada por una notificación de evento S3. CloudWatch no funciona así para eventos S3; DynamoDB Streams no aplica aquí; S3 no tiene esa funcionalidad nativa.

### 38. Los servicios de ECS corriendo en Fargate soportan...
- Application Load Balancers
- Network Load Balancers
- Classic Load Balancers
- Gateway Load Balancers

**Respuesta correcta:** Application Load Balancers; Network Load Balancers
**Por qué:** Fargate soporta ALB y NLB. Classic Load Balancer no es compatible con Fargate (solo con modo bridge en EC2); Gateway Load Balancer es para appliances de red de terceros, no para servicios ECS.

### 39. Un Security Group solo se puede adjuntar a una instancia EC2
- Verdadero
- Falso

**Respuesta correcta:** false
**Por qué:** Un mismo Security Group puede asociarse a múltiples instancias EC2 simultáneamente.

### 40. Al hacer push de una imagen Docker a ECR sin especificar tag, ¿qué hace ECR?
- Lanza un error "no image tag provided"
- Si hay una versión previa de esa imagen, ECR incrementa el tag y sube la imagen con el nuevo tag
- ECR asigna el tag "latest" y sube la imagen con ese tag
- La imagen se sube tal cual

**Respuesta correcta:** ECR set the "latest" tag and image will be uploaded with new tag
**Por qué:** Docker/ECR asignan automáticamente el tag "latest" si no se especifica ninguno, sin generar error ni incrementar versiones.

### 41. Tienes un ECR privado con imágenes para clusters multi-región. ¿Cómo asegurar disponibilidad con mínima latencia y alta disponibilidad?
- Amazon ECR puede replicar automáticamente imágenes a otras regiones y cuentas para despliegue en clusters multi-región
- Deberías crear un repositorio ECR separado en cada región
- Para lograrlo deberías pedirle a AWS Support que configure tu ECR como repositorio multi-región
- Solo es posible descargar imágenes dentro de la misma región donde está tu ECR

**Respuesta correcta:** Amazon ECR can automatically replicate images to other regions and accounts for deployment to multi-region clusters
**Por qué:** ECR soporta replicación cross-region/cross-account nativa configurada por el usuario, sin necesidad de repos separados manuales ni intervención de AWS Support.

### 42. Tienes RDS PostgreSQL en Singapur y necesitas backup con copia asíncrona de datos. ¿Qué opción usar?
- Habilitar Multi-AZ para la base de datos
- Habilitar Read Replicas para la base de datos
- Habilitar replicación asíncrona para la base de datos
- Habilitar backups manuales para la base de datos

**Respuesta correcta:** Enable Read Replicas for the database
**Por qué:** Las Read Replicas usan replicación asíncrona nativa de PostgreSQL. Multi-AZ es replicación síncrona (no accesible); "Asynchronous replication" no es un feature real de RDS; los manual backups son snapshots puntuales, no una base activa.

### 43. Tienes VPC Peering habilitado entre VPC A y B, pero las instancias EC2 no se comunican. ¿Qué revisar primero?
- Revisar la NACL
- Revisar los security groups de las instancias
- Revisar si la resolución DNS está habilitada
- Revisar las tablas de rutas de ambas VPCs

**Respuesta correcta:** Check the route tables of both VPCs
**Por qué:** Habilitar peering no configura rutas automáticamente; es el error más común y el primer punto a revisar. NACL/SG/DNS son pasos posteriores relevantes pero secundarios.

### 44. ¿Qué ocurre si un recurso en un stack de CloudFormation no puede crearse (parámetros por defecto)?
- CloudFormation crea o actualiza todos los recursos del stack sin importar si las operaciones individuales tuvieron éxito
- CloudFormation revierte el stack a la última configuración estable conocida
- CloudFormation elimina automáticamente todos los recursos si hay un fallo durante la creación o actualización
- CloudFormation elimina los recursos que no pudieron crearse y continúa con la creación/actualización

**Respuesta correcta:** Cloudformation automatically deletes all resources if there is a failure during creation or updating
**Por qué:** Por defecto (ROLLBACK), CloudFormation elimina todos los recursos creados si hay un fallo, dejando la cuenta en su estado previo. No continúa la creación ignorando el error, ni simplemente "revierte" a una config previa en creación (eso aplica más a updates).

### 45. Lanzas una EC2 con user data para aplicar actualizaciones, pero no se aplicaron. ¿Dónde ves los logs de ejecución del user data?
- En la instancia, en /var/log/cloud-init-output.log
- En tu máquina local, en /var/log/cloud-init-output.log
- En la instancia, en /var/log/user-data.log
- En tu máquina local, en /var/log/user-data.log

**Respuesta correcta:** On the instance /var/log/cloud-init-output.log
**Por qué:** cloud-init ejecuta el user data y guarda logs en /var/log/cloud-init-output.log DENTRO de la instancia, no en la máquina local. La ruta user-data.log no es el estándar de cloud-init.

### 46. ¿Cuál es un destino correcto para la acción Copy-AMI?
- Otra cuenta de AWS
- Otro bucket de S3
- Otra AZ
- Otra región
- La región actual
- Otro proveedor cloud
- Otra partición de AWS

**Respuesta correcta:** Another Region
**Por qué:** Copy AMI está diseñado principalmente para replicar hacia otra región. Compartir con otra cuenta usa launch permissions, no copy; AMIs no se copian a S3 directamente ni entre AZs (no están atadas a AZ); no aplica a otros cloud providers ni particiones AWS.

### 47. ¿Qué permiso permite a los servicios realizar acciones en tu nombre?
- sts:AssumeRole
- iam:PassRole
- iam:GetRole
- iam:RequestRole

**Respuesta correcta:** iam:PassRole
**Por qué:** iam:PassRole permite asignar un rol a un servicio para que actúe en tu nombre. AssumeRole es para que una identidad asuma un rol (distinto concepto); GetRole solo lee info; RequestRole no existe.

### 48. Elige todas las afirmaciones VERDADERAS relacionadas con VPC (6 opciones)
- Solo puedes tener una VPC por región
- El número máximo de CIDRs por VPC es 5
- El tamaño mínimo de un CIDR es /28
- Puedes tener múltiples VPCs por región (máx. 5 por región — se puede aumentar)
- Solo se permite un CIDR por VPC
- Puedes crear subnets con prefijo /8
- Es posible crear subnets solo con rangos IPv4
- Es posible crear subnets solo con rangos IPv6
- Adjuntar un IGW a una subnet agrega automáticamente una regla de enrutamiento hacia ese IGW
- La NACL por defecto deniega todo el tráfico inbound y outbound en la VPC

**Respuesta correcta:** Max number of CIDRs per VPC is 5; Min size of CIDR is /28; You can have multiple VPCs per region (max 5 per region - can be increased); It's possible to create subnets with IPv4 ranges only; It's possible to create subnets with IPv6 ranges only
**Por qué:** Verdaderas: máx. 5 CIDRs por VPC, tamaño mínimo /28, máx. 5 VPCs por región (ajustable), subnets solo IPv4 o solo IPv6 son posibles. Falsas: no hay límite de 1 VPC por región, no solo 1 CIDR permitido, no se permiten subnets /8 (fuera de rango /16-/28), adjuntar IGW no agrega rutas automáticamente, y la NACL por defecto permite todo el tráfico (no lo deniega).

### 49. Un equipo de DevOps provisiona infraestructura con CloudFormation y quiere hacer bootstrap de software en la creación del stack. ¿Es posible?
- No, CloudFormation no soporta bootstrapping de aplicaciones en la creación del stack
- Sí, abriendo un ticket de AWS Support y pidiéndoles que lo hagan
- Sí. CloudFormation provee un set de scripts de bootstrapping que permiten instalar paquetes, archivos y servicios en las instancias EC2
- Sí, CloudFormation puede integrarse con Systems Manager para mantener instalaciones de software con Automation Documents

**Respuesta correcta:** Yes. AWS CloudFormation provides a set of application bootstrapping scripts that enable you to install packages, files, and services on your EC2 instances; Yes, CloudFormation can be integrated with Systems Manager to maintain software installations with Systems Manager Automation Documents.
**Por qué:** CloudFormation incluye scripts de bootstrapping (cfn-init, etc.) vía AWS::CloudFormation::Init, y puede integrarse con Systems Manager Automation Documents. No requiere AWS Support ni es imposible.

### 50. ¿Qué servicio/feature identifica recursos de un stack modificados fuera de CloudFormation y los resincroniza?
- AWS CloudFormation drift detection
- AWS Managed service
- AWS Config
- AWS Recording Configuration

**Respuesta correcta:** AWS CloudFormation drift detection
**Por qué:** Drift Detection es la funcionalidad nativa de CloudFormation para este propósito. AWS Config rastrea cambios pero no compara contra plantillas de CloudFormation; las otras opciones no son servicios reales relevantes.

### 51. Elige las mejores prácticas de seguridad en AWS
- Otorgar el mínimo privilegio (least privilege)
- Habilitar MFA
- Usar roles para delegar permisos
- Guardar credenciales de AWS en un lugar "seguro" en GIT
- Usar un rol IAM dedicado por cada región de AWS

**Respuesta correcta:** Grant least privilege; Enable MFA; Use roles for delegating permissions
**Por qué:** Least privilege, MFA y usar roles para delegar permisos son mejores prácticas reales. Nunca se deben guardar credenciales en GIT (aunque se diga "seguro"); los IAM Roles son globales, no por región.

### 52. Quieres una notificación por email cuando la CPU de una EC2 supere el 80%. ¿Cuál es el mejor método?
- Ninguno de estos es un método correcto
- Crear una alarma de CloudWatch que dispare un "CloudWatch topic" para enviarte un mensaje
- Crear una alarma de billing que dispare cuando CPU Utilization supere 80%
- Crear una alarma de CloudWatch que dispare un topic de SNS para enviarte un mensaje

**Respuesta correcta:** Create a CloudWatch Alarm ... trigger an SNS topic to send you a message
**Por qué:** El flujo correcto es CloudWatch Alarm → SNS Topic → email. No existe "CloudWatch topic"; billing alarms son solo para gastos, no métricas de rendimiento.

### 53. Un Solutions Architect necesita enviar SMS a usuarios al registrarse en un evento. ¿Qué servicio de AWS usar?
- Amazon STS
- Amazon SQS
- AWS Lambda
- Amazon SNS

**Respuesta correcta:** Amazon SNS
**Por qué:** SNS es el servicio administrado para enviar SMS/notificaciones a usuarios finales. STS es para credenciales temporales; SQS son colas de mensajes internas; Lambda podría orquestar pero necesitaría invocar SNS.

### 54. ¿Cuáles son las opciones para enrutar tráfico con un Application Load Balancer? (3 opciones)
- Geolocalización del cliente
- Hostname
- Ruta de la URL del request
- Dirección IP de origen

**Respuesta correcta:** Hostname; Request URL path; Source IP address
**Por qué:** ALB soporta host-based routing, path-based routing y reglas basadas en source IP. El enrutamiento por geolocalización del cliente no es nativo de ALB (eso es de Route 53 o CloudFront).

### 55. Un cliente quiere cifrado en S3 pero gestionar sus propias claves sin almacenarlas nunca en AWS. ¿Qué recomiendas?
- Cifrado SSE-KMS
- Cifrado SSE-S3
- Cifrado del lado del cliente (Client Side Encryption)
- Cifrado SSE-C

**Respuesta correcta:** SSE-C Encryption
**Por qué:** SSE-C permite que el cliente provea sus propias claves, que AWS nunca almacena. SSE-KMS almacena las claves en KMS; SSE-S3 las gestiona S3 internamente; Client Side Encryption ocurre fuera de S3, no cumple "cifrado en S3".

### 56. ¿Cómo entiendes qué es observability?
- Trabajar con las mejores prácticas de AWS para que tu infraestructura sea altamente disponible y recuperable ante desastres
- Trabajar con las mejores prácticas de AWS para que tu infraestructura sea altamente disponible, recuperable ante desastres y optimizada en costos
- Observability provee análisis y evaluación de la recolección de datos de infraestructura para optimización posterior
- Observability te permite recolectar, correlacionar, agregar y analizar telemetría de tu red, infraestructura y aplicaciones para obtener insights sobre el comportamiento, rendimiento y salud de tu sistema

**Respuesta correcta:** Observability lets you collect, correlate, aggregate, and analyze telemetry in your network, infrastructure, and applications environments so you can gain insights into the behavior, performance, and health of your system
**Por qué:** Esta es la definición estándar de observability: recopilar, correlacionar y analizar telemetría para obtener insights de comportamiento, rendimiento y salud del sistema. Las demás describen pilares del Well-Architected Framework (HA, DR, costos), no observability en sí.

### 57. Una NACL tiene la regla #100 ALLOW 10.0.0.10/32 y la regla #200 DENY 10.0.0.10/32. ¿Cómo se evalúa?
- La IP será permitida
- La IP será denegada

**Respuesta correcta:** The IP address will be allowed
**Por qué:** Las reglas NACL se evalúan en orden numérico ascendente, deteniéndose en la primera coincidencia. La regla #100 (ALLOW) tiene número menor, se evalúa primero y permite el tráfico; la #200 nunca se evalúa.
