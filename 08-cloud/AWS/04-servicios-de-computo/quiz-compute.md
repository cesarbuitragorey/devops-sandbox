# Quiz de DevOps Bootcamp — AWS Compute

Preguntas, respuestas correctas y explicaciones. Material de repaso para el módulo 4 (Servicios de Cómputo).

---

### 1. Durante el lanzamiento de una instancia EC2 necesitas instalar paquetes de software adicionales. ¿Cuál es la mejor forma de hacerlo?
- SSH a la instancia e instalar manualmente
- Escribir un script bash y enviarlo a AWS Support para que lo ejecuten
- Escribir un script bash y usarlo en el EC2 User Data al lanzar la instancia
- Usar AWS CLI con 'aws ec2 modify-instance --user-data'

**Respuesta correcta:** Escribir un script bash y usarlo en el EC2 User Data al lanzar la instancia
**Por qué:** El User Data se ejecuta automáticamente una sola vez en el primer arranque, siendo la forma estándar de automatizar la instalación de software al lanzar la instancia.

### 2. ¿Cuáles son las afirmaciones verdaderas sobre Security Groups?
- Controlan el tráfico de entrada/salida de instancias EC2
- Contienen reglas allow y deny
- Las reglas pueden referenciar por IP o por security group
- Son stateless
- Gestionan acceso a puertos
- No pueden adjuntarse a múltiples instancias
- Están limitados a una región
- Todo el tráfico entrante/saliente está bloqueado por defecto

**Respuesta correcta:** Controlan tráfico de instancias EC2; reglas por IP o SG; gestionan puertos; todo bloqueado por defecto
**Por qué:** Los Security Groups son stateful, solo soportan reglas ALLOW, se pueden asociar a múltiples instancias, y bloquean todo por defecto salvo la regla de salida total que AWS agrega automáticamente.

### 3. ¿Cuál NO es una opción para conectarse a una nueva instancia EC2 Linux?
- SSH client
- Browser
- EC2 Instance Connect
- Public certificate
- Serial console

**Respuesta correcta:** Public certificate
**Por qué:** Para instancias Linux se usa un key pair (SSH), no un "certificado público"; las demás opciones sí son métodos válidos de AWS.

### 4. ASG con ALB Health Checks; una instancia EC2 es reportada como unhealthy. ¿Qué pasará?
- Nothing
- El ASG mantiene la instancia y reinicia la app
- El ASG desconecta (detach) la instancia unhealthy
- El ASG termina la instancia unhealthy

**Respuesta correcta:** El ASG termina la instancia unhealthy
**Por qué:** Cuando el ASG usa ALB Health Checks, marca y termina automáticamente las instancias unhealthy, lanzando una nueva para mantener la capacidad deseada.

### 5. t3.small con 2 vCPUs y baseline de 20%. ¿Cuántos créditos de CPU se ganan por hora?
- 12
- 6
- 24
- 36

**Respuesta correcta:** 12
**Por qué:** Tasa T3: 6 créditos/hora/vCPU al 100%. 2 vCPUs × 6 × 20% baseline = 12 créditos/hora.

### 6. ¿Se puede usar un AMI de us-east-1 para lanzar una instancia EC2 en otra región?
- Sí, se puede usar el AMI de una región en cualquier otra
- No, los AMIs se construyen para una región específica

**Respuesta correcta:** No, los AMIs se construyen para una región específica
**Por qué:** Un AMI es un recurso regional; para usarlo en otra región primero debes copiarlo (Copy AMI).

### 7. Aplicación de alto rendimiento y baja latencia que recibirá millones de solicitudes por segundo. ¿Qué tipo de ELB elegir?
- Network Load Balancer
- Classic Load Balancer
- Application Load Balancer

**Respuesta correcta:** Network Load Balancer
**Por qué:** El NLB opera en capa 4 y está diseñado para manejar millones de solicitudes por segundo con latencia ultra baja.

### 8. Servidor web multiplataforma con muy bajos requisitos de CPU/memoria/red (10 visitantes/hora) pero con 12TB de disco. ¿Qué opción es más costo-efectiva?
- t3.medium con gp3
- t4g.medium con gp2
- t3a.medium con gp3
- m4.large con gp3

**Respuesta correcta:** t3a.medium con gp3
**Por qué:** t4g es ARM (no "multiplataforma" x86); t3a (AMD) es más barata que t3 para carga baja; gp3 es más económico que gp2.

### 9. ¿Cuáles afirmaciones son verdaderas sobre instancias Burstable?
- Tienen CPU fija
- Tienen baseline de CPU con capacidad de burst por encima
- Tienen baseline de memoria con capacidad de burst
- Tienen memoria fija

**Respuesta correcta:** Tienen baseline de CPU con capacidad de burst por encima de ese nivel
**Por qué:** El mecanismo de créditos y burst aplica solo a CPU, no a memoria (la memoria es fija según el tamaño de instancia).

### 10. Instancia lanzada por CLI con User Data que instala actualizaciones, pero no se aplicaron. ¿Dónde ver los logs de ejecución del User Data?
- En la instancia: /var/log/cloud-init-output.log
- En tu máquina local: /var/log/cloud-init-output.log
- En la instancia: /var/log/user-data.log
- En tu máquina local: /var/log/user-data.log

**Respuesta correcta:** En la instancia: /var/log/cloud-init-output.log
**Por qué:** cloud-init ejecuta el User Data y registra toda la salida en ese archivo, dentro de la propia instancia.

### 11. Una ENI puede adjuntarse a instancias EC2 en otra AZ.
- false
- true

**Respuesta correcta:** false
**Por qué:** Una ENI vive en una subnet específica, ligada a una única AZ; solo puede adjuntarse a instancias en esa misma AZ.

### 12. Quieres que las métricas estándar de CloudWatch de EC2 se recolecten cada 1 minuto. ¿Qué hacer?
- Enable CloudWatch Custom Metrics
- Enable High Resolution Metrics
- Enable Basic Monitoring
- Enable Detailed Monitoring

**Respuesta correcta:** Enable Detailed Monitoring
**Por qué:** Basic Monitoring (default) recopila cada 5 minutos; Detailed Monitoring reduce el intervalo a 1 minuto (con costo adicional).

### 13. Escalar un ASG según el número de requests por minuto que la app envía a una base de datos standalone. ¿Qué hacer?
- Crear una CloudWatch custom metric y una alarma sobre ella para escalar el ASG
- Es imposible hacerlo
- Habilitar Detailed Monitoring y crear una alarma
- Pedir a AWS Support que cree la métrica

**Respuesta correcta:** Crear una CloudWatch custom metric y una alarma sobre ella para escalar el ASG
**Por qué:** Requests a una BD no es una métrica estándar; se debe publicar como custom metric y basar la alarma de escalado en ella.

### 14. ¿Cuáles son opciones para enrutar tráfico con Application Load Balancers? (3 puntos)
- Client geo-location
- Hostname
- Request URL path
- Source IP address

**Respuesta correcta:** Hostname; Request URL path; Source IP address
**Por qué:** El ALB soporta host-based routing, path-based routing y routing por IP de origen. No soporta geo-location (eso lo hacen Route 53/CloudFront).

### 15. Escalar una instancia EC2 de r4.large a r4.4xlarge se llama...
- Horizontal Scalability
- Vertical Scalability

**Respuesta correcta:** Vertical Scalability
**Por qué:** Cambiar el tamaño de una misma instancia es escalado vertical (scale up), no horizontal.

### 16. Ejecutar una app en un ASG que escala el número de instancias EC2 (in/out) se llama...
- Horizontal Scalability
- Vertical Scalability

**Respuesta correcta:** Horizontal Scalability
**Por qué:** Agregar/quitar instancias completas (in/out) es escalado horizontal.

### 17. ¿Qué protocolo(s) NO soporta el Application Load Balancer?
- HTTP
- HTTPS
- TCP
- WebSocket

**Respuesta correcta:** TCP
**Por qué:** El ALB opera en capa 7 (HTTP/HTTPS/WebSocket); para TCP puro se usa el Network Load Balancer.

### 18. NLB distribuye tráfico entre 2 instancias en us-east-1b y 5 en us-east-1a. El CPU es más alto en 1b y el tráfico se reparte igual entre AZs. ¿Cómo resolverlo?
- Enable Cross-Zone load balancing
- Enable Sticky Session
- Enable ELB health checks
- Enable SSL Termination

**Respuesta correcta:** Enable Cross-Zone load balancing
**Por qué:** Sin Cross-Zone LB, el tráfico se reparte por igual entre AZs sin importar el número de instancias en cada una. Al habilitarlo, se distribuye equitativamente entre todas las instancias.

### 19. Bastion Host en una AZ para acceder a EC2 en subnets privadas. Quieres alta disponibilidad ante desastre en una AZ. ¿Qué hacer?
- 2 Bastion Hosts en dos AZs enrutados con un Application Load Balancer
- 2 Bastion Hosts en dos AZs enrutados con un Network Load Balancer

**Respuesta correcta:** 2 Bastion Hosts en dos AZs enrutados con un Network Load Balancer
**Por qué:** El acceso SSH es TCP; el NLB (capa 4) soporta TCP, mientras que el ALB (capa 7) no soporta tráfico SSH/TCP puro.

### 20. ¿Por cuánto tiempo se puede mantener una EC2 Reserved Instance?
- 1 o 3 años
- Hasta 1 año
- Cualquier momento entre 1 y 3 años
- 1 mes o 3 meses
- 2 o 4 años

**Respuesta correcta:** 1 o 3 años
**Por qué:** AWS ofrece Reserved Instances solo con términos fijos de 1 año o 3 años.

### 21. ASG escala out por tráfico alto, lanza una instancia, pero no lanza más inmediatamente sino hasta después de 5 minutos aunque el tráfico siga subiendo. ¿Causa posible?
- Cooldown Period
- Lifecycle Hooks
- Target Tracking Policy
- Launch Template

**Respuesta correcta:** Cooldown Period
**Por qué:** El Cooldown Period (300s por defecto) evita que el ASG lance instancias adicionales inmediatamente después de una acción de escalado.

### 22. ASG en eu-west-2 con 3 instancias en eu-west-2a y 4 en eu-west-2b. Hay baja carga y el ASG hace scale-in. ¿Qué instancia se terminará?
- Instancia aleatoria en eu-west-2a
- Instancia en eu-west-2a con el Launch Template más antiguo
- Instancia aleatoria en eu-west-2b
- Instancia en eu-west-2b con el Launch Template más antiguo

**Respuesta correcta:** Instancia aleatoria en eu-west-2b
**Por qué:** El ASG primero busca balancear el número de instancias entre AZs; como 2b tiene más instancias, es la seleccionada para reducir.

### 23. Las instancias EC2 corren a nivel de...
- Global wide
- Regional
- AZ
- VPC

**Respuesta correcta:** AZ
**Por qué:** Aunque se lanzan dentro de una VPC/subnet, las instancias EC2 corren físicamente en una Availability Zone específica.

### 24. ¿Cuáles son tipos de instancia EC2 burstable?
- T4
- T4g
- T2
- T2a
- T3
- T3a

**Respuesta correcta:** T4g; T2; T3; T3a
**Por qué:** La familia burstable real incluye T2, T3, T3a y T4g. "T4" y "T2a" no existen como tipos de instancia.

### 25. ¿Qué opción de compra de EC2 da el mayor descuento pero no es adecuada para tareas críticas?
- Dedicated Hosts
- Dedicated Instances
- On-Demand Instances
- Spot Instances
- Reserved Instances

**Respuesta correcta:** Spot Instances
**Por qué:** Las Spot Instances ofrecen hasta 90% de descuento pero AWS puede interrumpirlas en cualquier momento, no aptas para cargas críticas.

### 26. Una nueva instancia EC2 puede lanzarse usando...
- Amazon image
- Launch specifications
- Launch template
- EBS root volume

**Respuesta correcta:** Amazon image; Launch template
**Por qué:** Se necesita un AMI para lanzar la instancia, y puede hacerse directamente o mediante un Launch Template que empaqueta toda la configuración.

### 27. Tienes un EC2 Key Pair para SSH a la instancia. Quieres obtener su Instance ID desde dentro. ¿Mejor forma?
- Crear un IAM Role y hacer describe-instances
- Consultar user data en https://169.254.169.254/latest/user-data
- Consultar metadata en http://169.254.169.254/latest/metadata
- Obtener el Instance ID de /etc/aws/instance_id

**Respuesta correcta:** Consultar metadata en http://169.254.169.254/latest/metadata
**Por qué:** El servicio de Instance Metadata (IMDS) permite consultar el instance-id y otra info desde dentro de la instancia sin credenciales adicionales.

### 28. Después de reiniciar, no puedes acceder a la instancia EC2 porque la IP pública cambió. ¿Cómo asignar una IP pública fija?
- Asignar una Elastic IP a la instancia
- Cambiar la config de red del SO a estática y asignar la IP pública
- Contactar a AWS Support y pedir una IP fija
- No se puede, solo se puede fijar la IP privada

**Respuesta correcta:** Asignar una Elastic IP a la instancia
**Por qué:** La IP pública por defecto es dinámica y cambia al detener/iniciar la instancia. Una Elastic IP permanece fija hasta que se libera.

### 29. ¿Qué usar para controlar tráfico de entrada y salida a nivel de instancia?
- Network Access Control List (NACL)
- IAM Policy
- Amazon Web Application Firewall (WAF)
- AWS Network Firewall
- Security Group

**Respuesta correcta:** Security Group
**Por qué:** El Security Group controla tráfico a nivel de instancia/ENI; las NACLs operan a nivel de subnet.

### 30. ¿Qué tipo de instancia EC2 elegir para tests de integración que corren rara vez en entorno no productivo?
- m5
- t4g
- r5
- i3

**Respuesta correcta:** t4g
**Por qué:** Instancia burstable basada en Graviton2 (ARM), la más económica para cargas esporádicas de bajo uso.

### 31. Batch job de ~4 horas que no debe interrumpirse. ¿Qué opción de compra con el menor costo elegir?
- Dedicated Instances
- On-Demand Instances
- Spot Instances
- Reserved Instances

**Respuesta correcta:** On-Demand Instances
**Por qué:** Spot puede interrumpirse (descartada). Reserved requiere compromiso largo (más caro para 4h). On-Demand es la más económica para uso puntual sin interrupciones.

### 32. ¿Qué tipo de instancia EC2 elegir para desplegar una aplicación de High-Performance Computing (HPC)?
- m5
- c7g
- r5
- i3

**Respuesta correcta:** c7g
**Por qué:** Familia Compute Optimized basada en Graviton3, diseñada para cargas intensivas en CPU como HPC.

### 33. ASG con desired=3 y maximum=3, configurado para escalar al 60% CPU. La app llega a 80% CPU. ¿Qué pasará?
- Nothing
- Desired sube a 4 y lanza nueva instancia
- Lanza nueva instancia pero desired queda en 3
- Desired y maximum suben a 4

**Respuesta correcta:** Nothing
**Por qué:** El ASG ya está en su capacidad máxima (3); no puede lanzar más instancias aunque se dispare la alarma de escalado.

### 34. ¿Cuál es un destino correcto para la acción AMI-Copy?
- Otra cuenta de AWS
- Otro bucket S3
- Otra AZ
- Otra región
- Región actual
- Otro proveedor de nube
- Otra partición de AWS

**Respuesta correcta:** Otra región
**Por qué:** Copy AMI está diseñado principalmente para copiar una AMI (recurso regional) de una región a otra.

### 35. ¿Cómo monitorear el uso de memoria de una instancia EC2 en CloudWatch?
- Enable EC2 Detailed Monitoring
- Usar el CloudWatch Agent para enviar memoria como custom metric
- EC2 envía memoria a CloudWatch por defecto
- Usar CloudWatch Logs

**Respuesta correcta:** Usar el CloudWatch Agent para enviar memoria como custom metric
**Por qué:** La memoria no es una métrica estándar de EC2; se necesita instalar el CloudWatch Agent para publicarla como métrica personalizada.

### 36. Un Security Group puede adjuntarse solo a una instancia EC2.
- true
- false

**Respuesta correcta:** false
**Por qué:** Un Security Group puede adjuntarse a múltiples instancias/ENIs simultáneamente.

### 37. Para clonar la configuración de una instancia existente, puedes crear...
- Back-up
- Instance snapshot
- Image
- EC2 package
- Launch template

**Respuesta correcta:** Image
**Por qué:** Se crea una AMI (Amazon Machine Image) a partir de la instancia, que luego permite lanzar instancias idénticas.

### 38. App de big data en EC2. Quieres el máximo rendimiento de red entre instancias. ¿Qué Placement Group elegir?
- Cluster Placement Group
- Dedicated Placement Group
- Spread Placement Group
- Distributed Placement Group
- Partition Placement Group

**Respuesta correcta:** Cluster Placement Group
**Por qué:** Agrupa las instancias físicamente cerca en la misma AZ/hardware, maximizando el rendimiento de red (baja latencia, alto throughput).

### 39. Elegir los modos de configuración soportados para instancias burstable (2 opciones)
- Standard
- Unlimited
- Restricted
- Unrestricted
- Intelligent

**Respuesta correcta:** Standard; Unlimited
**Por qué:** Standard: solo usa créditos acumulados. Unlimited: permite exceder el baseline consumiendo más allá de los créditos, con posible cargo adicional.
