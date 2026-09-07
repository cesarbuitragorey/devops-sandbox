# Quiz de DevOps Bootcamp — AWS Containers

Preguntas, respuestas correctas y explicaciones. Material de repaso para el módulo 8 (Servicios de Contenedores) — ECS, EKS, ECR y Fargate.

---

### 1. Is spot option available for Fargate?
- No, spot instances is the feature of EC2 only.
- Yes, with capacity provider functionality you can run your tasks on spot.

**Respuesta correcta:** Yes, with capacity provider functionality you can run your tasks on spot.
**Por qué:** ECS soporta Fargate Spot como un tipo de capacity provider (`FARGATE_SPOT`), permitiendo ejecutar tareas en capacidad Fargate sobrante con hasta 70% de descuento, configurado mediante una capacity provider strategy que mezcla `FARGATE` y `FARGATE_SPOT`.

### 2. In EKS you can run your pods on... (3 puntos)
- Self-managed node
- EKS managed node
- AWS Fargate node
- Elastic Beanstalk

**Respuesta correcta:** Self-managed node; EKS managed node; AWS Fargate node
**Por qué:** EKS soporta tres modos de cómputo: self-managed nodes (EC2 propios), EKS managed node groups (EC2 gestionados por EKS) y AWS Fargate (serverless). Elastic Beanstalk no es un mecanismo de cómputo para EKS.

### 3. Docker images storage. ¿Qué usar?
- Use AWS DynamoDB to store the Docker images
- Use AWS RDS to store the Docker images
- Use EC2 Instances with EBS Volumes to store the Docker images
- Use the ECR Service to store the Docker images

**Respuesta correcta:** Use the ECR Service to store the Docker images
**Por qué:** ECR es el servicio diseñado específicamente como registro de imágenes, integrado con ECS/EKS/CodeBuild, con escaneo de vulnerabilidades e IAM. DynamoDB/RDS son bases de datos; EC2+EBS requeriría gestionar manualmente un registro propio.

### 4. Migrar apps Docker on-premise sin gestionar infraestructura. ¿Qué servicio?
- Elastic Container Service in EC2 Launch mode
- Elastic Container Registry
- Elastic Container Service in Fargate Launch mode
- Elastic Kubernetes Service

**Respuesta correcta:** Elastic Container Service in Fargate Launch mode
**Por qué:** Fargate es serverless — AWS gestiona todo el cómputo. EC2 launch type requiere gestionar instancias; ECR es solo registro, no ejecución; EKS solo (sin especificar Fargate) aún exige elegir un modo de cómputo.

### 5. Pricing ECS EC2 vs Fargate
- Both charged based on EC2 instances and EBS volumes used
- Both charged based on ECS used per hour
- Both charged based on vCPU and memory resources requested
- ECS EC2: instancias EC2 + EBS. ECS Fargate: vCPU y memoria solicitados

**Respuesta correcta:** ECS with EC2 launch type is charged based on EC2 instances and EBS volumes used. ECS with Fargate launch type are charged based on vCPU and memory resources that the application requests
**Por qué:** Con EC2 se paga por la infraestructura subyacente sin importar el consumo real; con Fargate se paga exactamente por el vCPU/memoria solicitados por cada tarea, con granularidad por segundo. ECS (el plano de control) no tiene costo propio.

### 6. ECR multi-región con baja latencia y alta disponibilidad
- ECR puede replicar automáticamente imágenes a otras regiones/cuentas
- Crear un repositorio ECR separado en cada región
- Pedir a AWS Support que configure ECR multi-región
- Solo se puede hacer pull dentro de la misma región

**Respuesta correcta:** Amazon ECR can automatically replicate images to other regions and accounts for deployment to multi-region clusters
**Por qué:** ECR tiene replicación nativa cross-region y cross-account configurada a nivel de registro — se replica automáticamente en cada push, sin gestión manual ni soporte de AWS.

### 7. Push a ECR sin especificar tag. ¿Qué pasa?
- Error "no image tag provided"
- ECR incrementa el tag automáticamente
- ECR asigna el tag "latest"
- La imagen se sube "as is" sin tag

**Respuesta correcta:** ECR set the "latest" tag and image will be uploaded with new tag
**Por qué:** Docker asume por defecto el tag `latest` cuando no se especifica uno — comportamiento estándar del cliente Docker, sin lógica de auto-incremento en ECR.

### 8. ¿Cuál NO es componente de ECR?
- Registry
- Authorization token
- Dockerfile
- Image
- Repository
- Repository policy

**Respuesta correcta:** Dockerfile
**Por qué:** Un Dockerfile es parte del proceso de build local, no un componente que exista dentro de ECR. Los demás sí son componentes reales y documentados.

### 9. 6 microservicios en ECS, cada uno con permisos distintos. ¿Forma más segura?
- 6 roles IAM separados, uno por task definition
- Un IAM user compartido con credenciales pasadas a los contenedores
- Un IAM Instance Profile en las instancias EC2
- 6 roles IAM + un IAM group referenciado por el cluster

**Respuesta correcta:** Create six separate IAM roles with the required permissions for the associated ECS service, then configure each ECS task definition to reference the associated IAM role
**Por qué:** El ECS Task Role aplica mínimo privilegio a nivel de tarea individual. Un IAM user con credenciales estáticas es inseguro; un Instance Profile otorgaría los mismos permisos a todos los contenedores del host; los IAM Groups son para usuarios, no roles, y ECS no referencia grupos a nivel de clúster.

### 10. Afirmaciones VERDADERAS sobre ECS
- Launches containers on AWS
- AWS provisions & maintains EC2 worker nodes
- Has integrations with the Application Load Balancer
- AWS takes care of starting/stopping containers
- ECS doesn't support AWS Fargate

**Respuesta correcta:** Launches containers on AWS; Has integrations with the Application Load Balancer; AWS takes care of starting/stopping containers
**Por qué:** "AWS provisions & maintains EC2 worker nodes" solo aplica con Fargate, no con EC2 launch type. ECS sí soporta Fargate (incluyendo Fargate Spot).

### 11. ECS en Fargate soporta...
- Application Load Balancers
- Network Load Balancers
- Classic Load Balancers
- Gateway Load Balancers

**Respuesta correcta:** Application Load Balancers; Network Load Balancers
**Por qué:** ALB y NLB son compatibles vía registro de targets tipo IP (awsvpc networking). CLB solo funciona con modo bridge (solo EC2 launch type). GWLB es para appliances de red de terceros, no para balancear hacia tareas.

### 12. Opciones soportadas para ECS Service Auto Scaling
- Scaling based on average CPU and Memory Utilization
- Target tracking
- Step Scaling
- Scheduled scaling
- Scaled based on the number of tasks per instance
- All above options

**Respuesta correcta:** Target tracking; Step Scaling; Scheduled scaling
**Por qué:** Son los tres mecanismos válidos de Application Auto Scaling en ECS. CPU/memoria promedio es una métrica usada DENTRO de target tracking, no un mecanismo aparte; "tasks per instance" no existe.

### 13. Desplegar una AMI custom en nodos de un cluster EKS
- EKS managed node groups
- Self managed nodes
- AWS Fargate
- No se puede desplegar una AMI custom
- Pedir a AWS Support que la despliegue

**Respuesta correcta:** Create EKS cluster using Self managed nodes
**Por qué:** Con self-managed nodes tú creas y gestionas tus propios ASGs de EC2 con la AMI que elijas. Managed Node Groups usan las AMIs optimizadas de EKS; Fargate no tiene nodos EC2 visibles.

### 14. EKS con nodos EC2 self-managed. ¿Qué se paga?
- Solo la tarifa por hora de cada clúster EKS
- Solo los recursos AWS (EC2/EBS) de los worker nodes
- Tarifa por hora del clúster EKS + los recursos AWS de los worker nodes
- Precio fijo mensual

**Respuesta correcta:** You pay per-hour fee for each Amazon EKS cluster and for the AWS resources you create to run your Kubernetes worker nodes
**Por qué:** El modelo de precios de EKS tiene dos componentes: la tarifa fija por hora del control plane, y el costo de los recursos EC2/EBS de los worker nodes, sin importar el modo (self-managed o managed).

### 15. Fargate task con IP privada haciendo pull de ECR — mejor opción de seguridad
- Asignar IP pública al ENI de la tarea
- El pull ocurre por defecto sobre la IP privada
- Adjuntar un NAT gateway a la subnet privada
- Configurar ECR con un interface VPC endpoint (PrivateLink)
- Configurar el ECS agent para pull directo desde ECR

**Respuesta correcta:** Configure Amazon ECR to use an interface VPC endpoint and the image pull will occur over the task's private IPv4 address
**Por qué:** Un Interface VPC Endpoint (PrivateLink) para ECR permite el pull sin salir a internet en absoluto — la opción más segura. IP pública expone la tarea; sin ruta no hay pull posible; NAT gateway funciona pero es menos seguro (sale a internet); no existe un "pull directo" del agente que resuelva la conectividad.

### 16. ¿Qué tipo de deployment NO está disponible en ECS?
- Rolling update
- Recreate
- Blue/Green deployment
- External deployment

**Respuesta correcta:** Recreate
**Por qué:** Los controladores soportados por ECS son Rolling update, Blue/Green (con CodeDeploy) y External. "Recreate" es común en Kubernetes pero no existe en ECS.

### 17. ECS (EC2 launch type), tareas necesitan subir archivos a S3. ¿Qué rol modificar?
- EC2 instance Profile
- ECS Task Role

**Respuesta correcta:** ECS Task Role
**Por qué:** El Task Role se asocia a nivel de task definition, otorgando permisos solo a esa aplicación (mínimo privilegio). Modificar el Instance Profile daría acceso a S3 a todas las tareas de esa instancia.

### 18. Afirmaciones correctas sobre el ECS Container Agent
- Instalado en infraestructura AWS-managed, no hace falta hacer nada
- Preinstalado en todas las AMIs
- Debe instalarse obligatoriamente en todas las AMIs
- Incluido en la AMI ECS-optimizada
- Se puede instalar en cualquier EC2 que cumpla la especificación ECS
- Solo se puede instalar en instancias Linux
- Permite que las instancias se conecten al clúster, corre en cada recurso de infraestructura

**Respuesta correcta:** Incluido en la AMI ECS-optimizada; se puede instalar en cualquier EC2 que cumpla la especificación ECS; permite que las instancias se conecten al clúster
**Por qué:** El agente viene preinstalado solo en las AMIs ECS-optimizadas (no todas las AMIs genéricas), puede instalarse manualmente donde se cumpla la spec, y también soporta Windows (no solo Linux).

### 19. Afirmaciones VERDADERAS sobre el control plane de EKS
- EKS corre un control plane dedicado por cada clúster
- La infraestructura del control plane se comparte entre clústeres/cuentas
- El control plane tiene al menos 2 API servers y 3 instancias etcd en 3 AZs
- EKS monitorea la carga y escala automáticamente el control plane
- Reemplazar instancias unhealthy del control plane es responsabilidad tuya
- Los componentes del control plane no pueden verse desde otros clústeres/cuentas salvo RBAC

**Respuesta correcta:** dedicado por clúster; ≥2 API servers y 3 etcd en 3 AZs; escalado automático por EKS; aislamiento salvo RBAC
**Por qué:** Cada clúster tiene su propio control plane aislado, gestionado y escalado automáticamente por AWS — el reemplazo de instancias no saludables NO es responsabilidad del usuario, y la infraestructura NO se comparte entre cuentas/clústeres.

### 20. Con Fargate tienes que aprovisionar/configurar/escalar clusters de VMs.
- True
- False

**Respuesta correcta:** False
**Por qué:** Es justo lo contrario a la propuesta de valor de Fargate: AWS gestiona todo el aprovisionamiento, configuración y escalado de la infraestructura subyacente.

### 21. ECS (EC2), contenedores necesitan acceder a puertos del host. ¿Qué componente configurar?
- Service scheduler
- Service definition
- ECS Container Agent
- Task definition

**Respuesta correcta:** Task definition
**Por qué:** En la task definition se define el port mapping (`containerPort`/`hostPort`) de cada contenedor. El scheduler mantiene el conteo deseado; el agente solo aplica lo que la task definition especifica.

### 22. Minimizar instancias en uso — estrategia de placement por menor CPU/memoria disponible
- Binpack
- Random
- Spread
- Round-robin

**Respuesta correcta:** Binpack
**Por qué:** Binpack coloca tareas en la instancia con menos recursos disponibles, maximizando el uso de cada una antes de necesitar otra nueva. Random no optimiza, Spread distribuye uniformemente (lo opuesto), y Round-robin no es una estrategia válida de ECS.

### 23. ¿Qué estrategia de task placement NO es opción en ECS?
- binpack
- random
- round-robin
- spread

**Respuesta correcta:** round-robin
**Por qué:** Las únicas 3 estrategias soportadas son binpack, random y spread.

### 24. Webshop con dynamic port mapping y múltiples réplicas compartiendo la misma instancia EC2
- Application Load Balancer + ECS
- Classic Load Balancer + ECS
- Application Load Balancer + Beanstalk
- Network Load Balancer + ECS
- Classic Load Balancer + Beanstalk

**Respuesta correcta:** Application Load Balancer + ECS
**Por qué:** El ALB es el único LB que soporta dynamic port mapping con ECS (hostPort=0, ECS asigna puerto disponible, ALB registra dinámicamente cada tarea por IP/puerto). CLB no lo soporta; Beanstalk no es un orquestador como ECS.

### 25. Primer paso importante tras crear tu primer cluster EKS de prueba
- Deshabilitar el acceso público al cluster EKS
- Crear alertas de monitoreo
- Compartir el logro en internet
- Revisar el networking de los nodos

**Respuesta correcta:** Disable public access to EKS cluster
**Por qué:** Por defecto el endpoint público del API server está habilitado y accesible desde internet — buena práctica restringir/deshabilitarlo para reducir la superficie de ataque.

### 26. Feature que permite a un ALB redirigir tráfico a múltiples tareas ECS en la misma instancia
- Dynamic port mapping
- Automatic port mapping
- ECS Task Definition
- ECS Service

**Respuesta correcta:** Dynamic port mapping
**Por qué:** Con hostPort=0, ECS asigna un puerto efímero disponible por tarea, y el ALB rastrea y actualiza el target group con la combinación IP:puerto de cada una.

### 27. EKS con Fargate — ¿se puede hacer SSH al nodo para troubleshooting?
- Yes
- No

**Respuesta correcta:** No
**Por qué:** Con Fargate no existen instancias EC2 visibles ni gestionables — la infraestructura está completamente abstraída. Para depurar se usan CloudWatch Logs o ECS Exec.

### 28. ¿Es posible tener un repositorio público con ECR?
- No, solo repositorio privado
- Sí, Amazon ECR Public está disponible

**Respuesta correcta:** Sure - Amazon ECR Public is available.
**Por qué:** Amazon ECR Public permite crear repositorios de acceso público vía el ECR Public Gallery, donde cualquiera puede hacer pull sin autenticación.

### 29. Storage persistente multi-AZ compartido para tareas Fargate
- Montar volúmenes EFS
- Montar volúmenes EBS
- Fargate solo soporta volúmenes Docker
- No es posible montar storage multi-AZ en Fargate

**Respuesta correcta:** Mount EFS volumes onto tasks
**Por qué:** EFS soporta acceso multi-AZ nativo y puede montarse simultáneamente por múltiples tareas. EBS es de una sola AZ y solo lo monta una tarea a la vez.

### 30. Errores de conexión al cluster — ¿dónde revisar logs del control plane de EKS?
- CloudWatch Logs, porque EKS los guarda ahí por defecto
- CloudTrail
- Hay que habilitar el logging primero, luego revisar CloudWatch Logs
- Hay que habilitar el logging primero, luego revisar CloudTrail

**Respuesta correcta:** EKS doesn't have logging enabled by default, so you have to enable it first, then, check CloudWatch Logs
**Por qué:** El logging del control plane NO está habilitado por defecto; hay que habilitarlo explícitamente, y una vez habilitado va a CloudWatch Logs. CloudTrail registra llamadas a la API, no logs internos de Kubernetes.

### 31. Opciones de AWS como plataforma de gestión de contenedores
- Elastic Container Service
- Elastic Kubernetes Service
- Container Service
- Elastic Beanstalk
- Docker Manager
- All listed services

**Respuesta correcta:** Elastic Container Service; Elastic Kubernetes Service
**Por qué:** "Container Service" y "Docker Manager" no son servicios reales de AWS. Elastic Beanstalk es una plataforma de despliegue más amplia, no de orquestación de contenedores.

### 32. ¿Se pueden usar VPC Flow Logs para monitorear tráfico de una tarea Fargate?
- Yes
- No

**Respuesta correcta:** Yes
**Por qué:** Cada tarea Fargate recibe su propia ENI (modo awsvpc) con IP privada propia — VPC Flow Logs captura tráfico a nivel de ENI/subnet/VPC, por lo que es completamente posible.

### 33. Restringir tráfico a nivel de pod con security groups distintos por pod
- Sí, con EKS managed node y Linux
- Sí, con self-managed node con Linux y Windows
- Sí, con AWS Fargate
- No es posible
- No es posible por tu cuenta, pide a AWS Support

**Respuesta correcta:** Yes, if you use EKS managed node with Linux OS
**Por qué:** "Security Groups for Pods" usa ENI trunking en instancias Nitro con Linux. Windows no está soportado para esta función, ni Fargate. Se configura directamente por el usuario vía Kubernetes.

### 34. ¿Qué tipo de load balancer NO es opción para ECS Service?
- Application Load Balancer
- Network Load Balancer
- Classic Load Balancer
- Gateway Load Balancer
- Todos funcionan con ECS
- Ninguno funciona con ECS

**Respuesta correcta:** Gateway Load Balancer
**Por qué:** GWLB está diseñado para insertar appliances de red de terceros, no para el modelo de registro de targets de servicios de aplicación. ALB, NLB y CLB sí están soportados.

### 35. Compartir imágenes ECR entre múltiples cuentas AWS
- Sí, ECR soporta replicación cross-account
- No se pueden compartir imágenes entre cuentas

**Respuesta correcta:** Yes, Amazon ECR supports a cross-account replication of the images
**Por qué:** ECR ofrece replicación cross-account (además de cross-region) a nivel de registro, y también repository policies basadas en IAM para compartir acceso sin duplicar la imagen.

### 36. Formas seguras de almacenar imágenes en un registro ECR privado
- Cifrar con KMS manualmente antes de subir
- ECR cifra automáticamente en reposo con S3 SSE
- ECR permite cifrar en reposo con KMS
- Configurar políticas IAM para gestionar permisos y acceso
- Gestionar credenciales directamente en las instancias EC2

**Respuesta correcta:** ECR cifra automáticamente con SSE-S3; permite cifrado KMS; políticas IAM para control de acceso
**Por qué:** Por defecto ECR usa SSE-S3 automático, y KMS es una alternativa configurable a nivel de repositorio (no manualmente antes del push). Gestionar credenciales directamente en EC2 no es práctica recomendada frente a roles IAM.

### 37. ECS EC2, segunda app con errores de autorización a S3 (la primera ya llama a DynamoDB bien)
- Editar el rol de la instancia EC2 para agregar permisos a S3
- Crear un IAM task role para la nueva aplicación
- Habilitar el modo Fargate
- Editar la bucket policy de S3 para permitir la tarea ECS

**Respuesta correcta:** Create an IAM task role for the new application
**Por qué:** Cada aplicación debe tener su propio Task Role (mínimo privilegio), sin mezclar permisos con la app existente. Modificar el rol de instancia daría acceso a S3 a todas las tareas del host.

### 38. ¿Qué se puede definir en una ECS task definition?
- La configuración de la aplicación
- Las imágenes de contenedor y sus repositorios
- Las reglas de security group
- Los puertos que deben abrirse en la instancia de contenedor

**Respuesta correcta:** La configuración de la aplicación; imágenes/repositorios; puertos a abrir
**Por qué:** Los security groups no se configuran en la task definition — se asocian a nivel de red del servicio cuando se usa el modo awsvpc.

### 39. Rolling Update de 4 tareas V1→V2, Min 100%, Max 150%
- Lanza 2 V2, destruye 2 V1, lanza 2 V2
- Destruye 2 V1, lanza 4 V2, destruye 2 V1
- Lanza 4 V2, destruye 4 V1
- Destruye 4 V1, lanza 4 V2
- Todas son correctas

**Respuesta correcta:** Launch two tasks V2. Destroy two tasks V1. Launch two tasks V2
**Por qué:** Con 4 tareas, min 100% = nunca menos de 4 corriendo; max 150% = nunca más de 6 simultáneas. ECS lanza 2 V2 (total 6, en el máximo), destruye 2 V1 (total 4, en el mínimo), y repite. Las demás opciones violan el mínimo o el máximo en algún punto.

### 40. ¿Qué NO es un componente de ECS?
- Cluster
- Node group
- Task
- Service

**Respuesta correcta:** Node group
**Por qué:** "Node group" es un concepto de EKS (Managed Node Groups). ECS usa "Container Instances" en su lugar.

### 41. Infraestructura AWS-managed para correr y almacenar contenedores sin gestionar EC2 (elegir 2)
- ECS con Fargate Launch Type
- ECS con EC2 Launch Type
- Poner las imágenes en un repositorio privado (genérico)
- CloudFormation para desplegar Docker en EC2
- Poner las imágenes en ECR

**Respuesta correcta:** Use ECS with the Fargate Launch Type; Put your container images in the ECR
**Por qué:** Fargate es serverless (sin gestionar EC2) y ECR es el registro administrado de AWS. EC2 launch type y CloudFormation-para-Docker-en-EC2 contradicen el requisito; "private repository" genérico es menos específico que ECR.

### 42. ¿Qué es un componente de Amazon ECR?
- Registry
- Authorization token
- Repository
- Repository policy
- Image
- All of mentioned points
- None of mention points

**Respuesta correcta:** All of mentioned points
**Por qué:** Registry, Authorization token, Repository, Repository policy e Image son todos componentes reales y documentados de ECR.

### 43. Pods que necesitan usar más CPU/memoria de la solicitada (burst) si hay recursos disponibles en el nodo
- EKS managed node groups
- Self managed nodes
- AWS Fargate
- Elastic Beanstalk

**Respuesta correcta:** EKS managed node groups; Self managed nodes
**Por qué:** En nodos basados en EC2 (managed o self-managed), los pods comparten el pool de recursos del nodo y pueden hacer burst más allá de lo solicitado. En Fargate cada pod tiene una asignación fija y aislada, sin burst posible. Beanstalk no tiene relación con el cómputo de pods de EKS.

### 44. Migrar sitio Docker on-premise a ECS, contenedores necesitan compartir el mismo contenido (archivos, imágenes, videos)
- Montar un volumen EFS
- Montar un volumen EBS
- Usar un EC2 Instance Store
- Montar un volumen Docker

**Respuesta correcta:** Mount an EFS volume
**Por qué:** EFS permite que múltiples contenedores/tareas monten el mismo sistema de archivos simultáneamente, compartiendo contenido en tiempo real entre instancias/AZs distintas. EBS solo lo monta una tarea a la vez; Instance Store es efímero y local; los volúmenes Docker nativos son locales al host.
