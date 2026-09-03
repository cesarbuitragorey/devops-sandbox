# Quiz de Networking — AWS

Preguntas, respuestas correctas y explicaciones. Material de repaso para el módulo 3 (Redes, DNS y Entrega de Contenido).

---

### 1. Security groups act like a firewall at the instance level, whereas ___ are an additional layer of security that act at the subnet level.
- Network ACLs
- Database Security Groups
- Route Tables
- VPC Security Groups

**Respuesta correcta:** Network ACLs
**Por qué:** Los Security Groups funcionan a nivel de instancia y son stateful. Las Network ACLs operan a nivel de subred y son stateless (requieren reglas explícitas de entrada y salida).

### 2. True or False: A subnet can span multiple Availability Zones.
- True
- False

**Respuesta correcta:** False
**Por qué:** Cada subnet vive en una sola Availability Zone. Es la VPC la que puede abarcar múltiples AZs, creando subnets separadas en cada una.

### 3. VPC Endpoints allows you..
- To connect to AWS services using a private network instead of using the public internet
- To connect your on-premise data center to AWS resources
- To connect your VPCs transitively
- To connect VPCs between different accounts

**Respuesta correcta:** To connect to AWS services using a private network instead of using the public internet
**Por qué:** Un VPC Endpoint permite conectar tu VPC a servicios de AWS sin salir a internet, usando la red privada de AWS (Gateway Endpoints para S3/DynamoDB, Interface Endpoints basados en PrivateLink para el resto).

### 4. NACL rule: #100 ALLOW 10.0.0.10/32 y #200 DENY 10.0.0.10/32. ¿Cómo se evaluará esta regla?
- The IP address will be allowed
- The IP address will be denied

**Respuesta correcta:** The IP address will be allowed
**Por qué:** Las reglas de NACL se evalúan en orden numérico ascendente. La regla #100 (ALLOW) coincide primero y se detiene la evaluación, por lo que la #200 nunca se evalúa.

### 5. 5 VPCs en configuración hub-and-spoke, VPC 'A' en el centro peereada individualmente con B, C, D y E. ¿Con qué VPCs puede comunicarse B directamente?
- VPCs 'A', 'C', 'D', y 'E'
- VPCs 'A' y 'E'
- VPC 'A'
- VPCs 'A' y 'C'

**Respuesta correcta:** VPC 'A'
**Por qué:** El VPC Peering no es transitivo. B solo tiene peering directo con A, por lo que solo puede comunicarse con A.

### 6. ¿Cuál de las siguientes afirmaciones es verdadera?
- Both Security Groups and Network ACLs are stateless.
- Both security groups and NACLs are stateful.
- Security groups are stateful and NACLs are stateless.
- Security groups are stateless and NACLs are stateful.

**Respuesta correcta:** Security groups are stateful and NACLs are stateless.
**Por qué:** Security Groups son stateful (el tráfico de respuesta se permite automáticamente). NACLs son stateless (se necesitan reglas explícitas en ambas direcciones).

### 7. ¿Cuál ofrece el mayor rango de IPs internas?
- /28
- /22
- /16
- /20

**Respuesta correcta:** /16
**Por qué:** Cuanto menor el número de prefijo CIDR, mayor el rango de direcciones. /16 = 65,536 direcciones, la mayor de las opciones.

### 8. Redes corporativas 10.0.0.0/8 y 192.168.0.0/16. ¿Qué CIDR es aceptable para una nueva VPC que se conectará con estas redes?
- 172.16.0.0/12
- 172.16.0.0/16
- 10.0.32.0/16
- 192.168.8.0/18
- 192.168.0.0/8
- 172.168.0.0/8

**Respuesta correcta:** 172.16.0.0/16
**Por qué:** No debe solaparse con las redes existentes y debe cumplir el tamaño máximo permitido para una VPC (/16). /12 excede el límite; el resto se solapa con las redes existentes.

### 9. CloudFront + ALB + EC2. Todos los clientes son de EE.UU. pero llegan solicitudes maliciosas de otros países. ¿Cómo permitir solo EE.UU. y bloquear el resto?
- Use CloudFront Geo Restriction
- Use Origin Access Identity
- Set up a security group and attach it to your CloudFront Distribution
- Use a Route 53 Latency record and attach it to CloudFront

**Respuesta correcta:** Use CloudFront Geo Restriction
**Por qué:** CloudFront Geo Restriction permite restringir el acceso según el país de origen usando allowlist o blocklist.

### 10. Actualizaste un registro de Route 53 (myapp.mycompany.com) para apuntar a un nuevo ELB, pero los usuarios siguen siendo redirigidos al ELB antiguo. ¿Posible causa?
- Because of the Alias record configuration
- Because of the CNAME record configuration
- Because of TTL configuration
- Because of Route 53 Health Checks configuration

**Respuesta correcta:** Because of TTL configuration
**Por qué:** Un TTL largo hace que los resolvers DNS mantengan el valor anterior en caché hasta que expire, aunque el registro ya se haya actualizado.

### 11. ¿Cuáles son afirmaciones VERDADERAS sobre Transit Gateway? (4 puntos)
- Transit gateway routes only IPv4 packets
- You can connect multiple VPCs through the Transit Gateway
- Transit Gateway supports transitive peering between thousands of VPCs and on-premises
- You cannot share Transit Gateway across accounts
- You can peer Transit Gateway across regions
- Route tables are used to limit which VPC can talk to other VPCs
- Doesn't support connections with Direct Connect Gateway and VPN connections

**Respuesta correcta:** Puede conectar múltiples VPCs; soporta peering transitivo entre miles de VPCs y on-premises; se puede peerear entre regiones; las route tables limitan qué VPC puede hablar con otra
**Por qué:** Transit Gateway soporta IPv4 e IPv6 (no solo IPv4), sí se puede compartir entre cuentas vía AWS RAM, y sí soporta Direct Connect Gateway y VPN — por eso esas 3 opciones son falsas.

### 12. Aplicación web interna en EC2 dentro de tu VPC. Necesitas exponerla a otras VPCs de clientes de AWS sin abrir a internet ni exponer toda tu VPC. ¿Qué usar?
- Use NAT Gateway
- Use VPC Endpoint Services
- Use VPC Peering
- Transit Gateway

**Respuesta correcta:** Use VPC Endpoint Services
**Por qué:** VPC Endpoint Services (basado en AWS PrivateLink) permite exponer un servicio específico a otras VPCs sin exponer toda la red, usando un NLB del lado del servicio y un Interface Endpoint del lado del consumidor.

### 13. Conectar tu data center on-premise a una o más VPC en distintas regiones (misma cuenta). ¿Qué usar?
- Direct Connect Gateway
- It is not possible
- Customer Gateway
- VPC Peering

**Respuesta correcta:** Direct Connect Gateway
**Por qué:** Direct Connect Gateway permite conectar tu conexión Direct Connect a múltiples VPCs en diferentes regiones sin necesitar una conexión separada por región.

### 14. Website estático en S3 servido a través de CloudFront. Quieres forzar que los usuarios accedan solo por CloudFront. ¿Cómo lograrlo?
- Send an email to your client and inform them to not use the S3 endpoint
- Configure your CloudFront Distribution and create the Origin Access Identity, then update your S3 Bucket Policy to only accept requests from your CloudFront Distribution OAI user
- Configure routing rules to redirect requests from S3 to CloudFront
- Use S3 Access Points to redirect clients to CloudFront

**Respuesta correcta:** Configure your CloudFront Distribution and create the Origin Access Identity, then update your S3 Bucket Policy to only accept requests from your CloudFront Distribution OAI user
**Por qué:** La Origin Access Identity (OAI) es una identidad especial usada por CloudFront para acceder al bucket. Al restringir la Bucket Policy de S3 a solo esa OAI, se bloquea el acceso directo al endpoint S3.

### 15. ¿Cuáles afirmaciones son verdaderas sobre AWS PrivateLink? (Elegir 3)
- Most secure and scalable way to expose a service to 1000s of VPC
- Require VPC Peering
- Doesn't require Internet Gateway, NAT, route tables
- Require Network Load Balancer (Service VPC) and VPC Endpoint

**Respuesta correcta:** Most secure and scalable...; Doesn't require Internet Gateway, NAT, route tables; Require Network Load Balancer (Service VPC) and VPC Endpoint
**Por qué:** PrivateLink no requiere VPC Peering — precisamente esa es una de sus ventajas. Usa ENIs/NLB directamente, sin necesidad de rutas tradicionales.

### 16. ¿Cuál de las siguientes afirmaciones describe las Network ACLs? (2 puntos)
- Responses to allowed inbound traffic are allowed to flow outbound regardless of outbound rules, and vice versa (are stateless)
- Using NACLs, you can deny access from a specific IP range
- Keep NACL rules simple and use a Security Groups to restrict access on application level
- NACLs are associated with a single Availability Zone (associated with Subnet)

**Respuesta correcta:** Using NACLs, you can deny access from a specific IP range; NACLs are associated with a single Availability Zone (associated with Subnet)
**Por qué:** Las NACLs permiten reglas DENY explícitas por rango de IP, y al asociarse a una subnet quedan ligadas a una única AZ. La primera opción describe erróneamente el comportamiento stateful de los Security Groups; la NACL es stateless.

### 17. Dar acceso a Internet con IPv4 a EC2 en subnets privadas con la menor administración posible. ¿Qué usar?
- NAT Gateway
- Internet Gateway Egress only
- NAT Instances
- Virtual Private Gateway

**Respuesta correcta:** NAT Gateway
**Por qué:** El NAT Gateway es un servicio completamente administrado por AWS (escalado, alta disponibilidad, mantenimiento), a diferencia de NAT Instances que requieren administración propia.

### 18. Elegir todas las afirmaciones VERDADERAS relacionadas con VPC (6 puntos)
- You can have only one VPC per region
- Max number of CIDRs per VPC is 5
- Min size of CIDR is /28
- You can have multiple VPCs per region (max 5 per region - can be increased)
- Only one CIDRs per VPC allowed
- You can create subnets with /8 prefix
- It's possible to create subnets with IPv4 ranges only
- It's possible to create subnets with IPv6 ranges only
- IGW attachment to subnet automaticaly adds routing rule to that IGW
- Default Network ACL denies all inbound and outbound traffic in VPC

**Respuesta correcta:** Max 5 CIDRs por VPC; tamaño mínimo de CIDR /28; múltiples VPCs por región (máx 5, ampliable); subnets solo con IPv4
**Por qué:** Máx. 5 VPCs/región (ampliable), máx. 5 CIDRs/VPC, rango válido /16 a /28, y toda subnet requiere IPv4 obligatoriamente (IPv6 es opcional adicional). No hay una VPC única por región, no hay límite de un solo CIDR, no se permiten subnets /8, y adjuntar un IGW NO agrega la ruta automáticamente (debe hacerse manualmente).

### 19. Conexión dedicada de 10Gbps entre tu datacenter on-premises y AWS Cloud, privada, sin pasar por internet. ¿Qué servicio usar?
- Site-to-Site VPN
- AWS PrivateLink
- AWS Direct Connect
- Amazon EventBridge
- VPC Peering

**Respuesta correcta:** AWS Direct Connect
**Por qué:** Direct Connect ofrece una conexión física dedicada y privada con anchos de banda hasta 100 Gbps, sin pasar por internet público. La VPN sí usa internet, por lo que no cumple el requisito.

### 20. Requisito legal: solo usuarios de Alemania pueden acceder al sitio. ¿Qué política de enrutamiento de Route 53 ayuda a lograrlo?
- Latency
- Simple
- Multi Value
- Geolocation

**Respuesta correcta:** Geolocation
**Por qué:** La política Geolocation enruta el tráfico DNS según la ubicación geográfica del usuario, permitiendo restringir el acceso por país.

### 21. ¿Qué corresponde al bloque CIDR 10.0.6.0/28?
- 10.0.6.0 - 10.0.6.28
- 10.0.6.0 - 10.0.16.0
- 10.0.6.0 - 10.0.0.15
- 10.0.6.0 - 10.0.6.16
- 10.0.6.0 - 10.0.6.15

**Respuesta correcta:** 10.0.6.0 - 10.0.6.15
**Por qué:** /28 deja 4 bits para host = 16 direcciones (2^4). El rango va de 10.0.6.0 a 10.0.6.15.

### 22. VPC Flow Logs muestran Inbound ACCEPT y Outbound REJECT para la misma IP. ¿Qué revisar primero para troubleshooting?
- Check the NACL
- Check the SG
- Check the Route table
- Check the ENI configuration
- SSH to EC2 and check network configuration
- Check the Amazon WAF rules

**Respuesta correcta:** Check the NACL
**Por qué:** Este patrón asimétrico (ACCEPT en un sentido, REJECT en el otro) es típico de las NACLs, que son stateless y evalúan cada dirección de forma independiente. Un Security Group (stateful) no podría generar este comportamiento.

### 23. Cuando creo un nuevo security group, todo el tráfico de salida está permitido por defecto.
- True
- False

**Respuesta correcta:** True
**Por qué:** Un nuevo Security Group viene con una regla de salida que permite todo el tráfico (0.0.0.0/0) por defecto, y sin reglas de entrada (todo bloqueado).

### 24. ¿Cuál de las siguientes afirmaciones es FALSA sobre NAT Gateway?
- AWS managed NAT has higher bandwidth than NAT Instance
- Pay per hour for usage and amount of data transferred
- NAT Gateway is created in specific AZ
- Can be used by EC2 Instance in the same subnet
- Requires an Internet Gateway
- No Security Groups to manage

**Respuesta correcta:** Can be used by EC2 Instance in the same subnet
**Por qué:** El NAT Gateway se coloca en una subred pública para dar salida a instancias en subredes privadas (diferentes). No tiene sentido usarlo desde una instancia en la misma subred pública, ya que esta ya tiene acceso directo a internet.

### 25. ¿Cuáles son los tipos de VPC Endpoints? (Elegir 2)
- Interface Endpoint
- Gateway Endpoint
- PrivateLink Endpoint
- DirectConnect Endpoint

**Respuesta correcta:** Interface Endpoint; Gateway Endpoint
**Por qué:** AWS define solo dos tipos: Gateway Endpoint (S3 y DynamoDB) e Interface Endpoint (basado en PrivateLink, para el resto de servicios).

### 26. Dominio comprado en GoDaddy, quieres usar Route 53 como proveedor de DNS. ¿Qué hacer?
- Request for a domain transfer
- Create a Private Hosted Zone and update the 3rd party Registar NS records
- Create a Public Hosted Zone and update the Route 53 NS records
- Create a Public Hosted Zone and update the 3rd party Registar NS records

**Respuesta correcta:** Create a Public Hosted Zone and update the 3rd party Registar NS records
**Por qué:** Se crea una Public Hosted Zone en Route 53 (genera 4 NS records) y se actualizan esos NS records en el registrador (GoDaddy) para delegar la resolución DNS a Route 53.

### 27. ¿Cuáles son los únicos dos servicios de AWS con Gateway Endpoint disponible?
- Amazon S3 and Amazon SQS
- Amazon SQS and DynamoDB
- Amazon S3 and DynamoDB

**Respuesta correcta:** Amazon S3 and DynamoDB
**Por qué:** Los Gateway Endpoints solo están disponibles para S3 y DynamoDB. El resto de servicios usa Interface Endpoints.

### 28. Al hacer VPC Peering, solo puedes peerear tu VPC con otra VPC de tu misma cuenta de AWS.
- True
- False

**Respuesta correcta:** False
**Por qué:** El VPC Peering también puede establecerse con VPCs de cuentas de AWS distintas, además de en regiones diferentes.

### 29. ¿Cuáles de las siguientes son verdaderas para security groups? (3 puntos)
- Security groups operate at the instance level and are associated with network interfaces.
- Security groups process rules based on order they are provided when deciding whether to allow traffic.
- Security groups operate at the subnet level.
- Security groups support both "allow" and "deny" rules.
- Security groups support "allow" rules only.
- Security groups evaluate all rules before deciding whether to allow traffic.

**Respuesta correcta:** Operan a nivel de instancia/ENI; soportan solo reglas "allow"; evalúan todas las reglas antes de decidir
**Por qué:** Los Security Groups se asocian a ENIs, solo permiten reglas ALLOW (nunca DENY), y evalúan todas las reglas (no se detienen en la primera coincidencia como las NACLs, que sí tienen orden y operan a nivel de subnet).

### 30. ¿Desde qué servicios puedo bloquear IPs de entrada/salida?
- Security Groups
- ELB
- NACL
- DNS
- VPC subnet

**Respuesta correcta:** NACL
**Por qué:** Solo las Network ACLs permiten bloquear (DENY) explícitamente IPs específicas. Los Security Groups solo tienen reglas ALLOW.

### 31. ¿Cuál es la mejor práctica para configurar un Bastion Host?
- Avoid exposing port 22 to the public, limit it to your users instead
- For simplicity of configuration, exposing port 22 to the public
- Make sure the Bastion Host only has port 22 traffic allowed in the security groups
- The Bastion Host should be created only in the private subnet for security reason

**Respuesta correcta:** Avoid exposing port 22 to the public, limit it to your users instead
**Por qué:** El puerto SSH (22) debe restringirse solo a IPs de usuarios/administradores autorizados, nunca exponerse a 0.0.0.0/0. El Bastion Host debe estar en subred pública, no privada.

### 32. VPC Peering habilitado entre VPC A y B, pero las instancias EC2 no pueden comunicarse. ¿Qué revisar primero?
- Check the NACL
- Check instances security groups
- Check if DNS resolution is enabled
- Check the route tables of both VPCs

**Respuesta correcta:** Check the route tables of both VPCs
**Por qué:** El peering no habilita automáticamente el enrutamiento. Debes agregar manualmente rutas en ambas VPCs apuntando al peering connection. Es el error más común y el primer punto a revisar.

### 33. ¿Cómo obtener información sobre el tráfico IP dentro de tus VPCs?
- Enable VPC Flow Logs
- Enable VPC Traffic Monitoring
- Enable CloudWatch Traffic Logs
- Enable VPC Traffic Mirroring

**Respuesta correcta:** Enable VPC Flow Logs
**Por qué:** VPC Flow Logs captura metadata del tráfico IP (origen/destino, puertos, acción, etc.). VPC Traffic Mirroring copia paquetes completos para análisis profundo, pero no es la respuesta estándar aquí.

### 34. ¿Cuál es el tamaño mínimo de subnet necesario para lanzar 59 instancias EC2?
- /27
- /26
- /25
- /28
- /24

**Respuesta correcta:** /26
**Por qué:** AWS reserva 5 IPs por subnet. /26 = 64 IPs totales - 5 = 59 IPs utilizables, exactamente lo necesario.

### 35. Dominio myapp.com comprado en Route 53 Registrar. Quieres que el TLD apunte a un Elastic Load Balancer. ¿Qué tipo de registro usar?
- CNAME
- Alias
- TXT - record
- A - record

**Respuesta correcta:** Alias
**Por qué:** CNAME no está permitido en el dominio raíz (zone apex). El registro Alias sí lo permite y es la forma recomendada de apuntar hacia recursos de AWS como un ELB.

### 36. Un consultor sugiere dejar todos los security groups en subnets públicas abiertos en puerto 22 a 0.0.0.0/0. ¿Es un buen diseño de seguridad?
- Yes
- No

**Respuesta correcta:** No
**Por qué:** Exponer SSH (22) a todo internet es una práctica de seguridad muy riesgosa; debe restringirse a IPs específicas o usar un Bastion Host / Session Manager.

### 37. Conexión interna en tu VPC por nombre DNS usando una Private Hosted Zone. ¿Qué configuración de VPC debes activar?
- Enable DNS Hostnames only
- Enable DNS Resolution only
- Enable both DNS Hostnames and DNS Resolution

**Respuesta correcta:** Enable both DNS Hostnames and DNS Resolution
**Por qué:** AWS requiere que ambos atributos (`enableDnsSupport` y `enableDnsHostnames`) estén activados para que la resolución DNS de una Private Hosted Zone funcione correctamente.

### 38. Una Elastic Network Interface (ENI) puede adjuntarse a instancias EC2 en otra AZ.
- true
- false

**Respuesta correcta:** false
**Por qué:** Una ENI vive en una subnet específica, y por lo tanto en una única AZ. Solo puede adjuntarse a instancias en esa misma AZ.

### 39. Sitio web detrás de CloudFront. Un usuario solicita una imagen. ¿Qué acciones realiza CloudFront? (Elegir 3)
- CloudFront checks its cache and if the requested file exists send it to the edge location
- CloudFront checks its cache and if the requested file exists send it to the user
- If the file is not in the cache Cloudfront returns 404 response
- If the file is not in the cache Cloudfront forwards the request for the file to the origin server
- As soon as the first byte arrives from the origin, CloudFront begins to forward the file to the user
- As soon as the file arrives from the origin, CloudFront save it to the cache and only after that begins to forward the file to the user

**Respuesta correcta:** Revisa caché y envía al usuario si existe; si no está, reenvía al origen; al llegar el archivo, primero lo guarda en caché y luego lo envía al usuario
**Por qué:** Flujo estándar: cache hit → sirve directo al usuario; cache miss → reenvía al origen; al recibir el archivo, primero se guarda en caché y luego se entrega, no antes.

### 40. Elegir todos los tipos de Route 53 Hosted Zones (Elegir 2)
- Public Hosted Zone
- Private Hosted Zone
- VPC Hosted Zone
- CloudFront Hosted Zone

**Respuesta correcta:** Public Hosted Zone; Private Hosted Zone
**Por qué:** Route 53 define solo dos tipos: Public (para internet) y Private (para resolución dentro de VPCs). 'VPC Hosted Zone' y 'CloudFront Hosted Zone' no existen como tipos.

### 41. ¿Cuál de las siguientes NO podría ser el target de un Alias Record (Route 53)?
- Elastic Load Balancer
- Amazon CloudFront
- S3 Websites
- Amazon API Gateway
- Elastic Beanstalk
- EC2 DNS name

**Respuesta correcta:** EC2 DNS name
**Por qué:** Los Alias records solo pueden apuntar a recursos específicos de AWS soportados (ELB, CloudFront, S3 Websites, API Gateway, Elastic Beanstalk, etc.). Un EC2 DNS name no es un target válido para Alias; requeriría un registro A o CNAME tradicional.
