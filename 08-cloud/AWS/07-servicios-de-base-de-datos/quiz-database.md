# Quiz de DevOps Bootcamp — AWS Database

Preguntas, respuestas correctas y explicaciones. Material de repaso para el módulo 7 (Servicios de Base de Datos).

---

### 1. Your organization is building a collaboration platform... they would like to increase the number of connections to RDS instance. How can this be achieved?
- Login to RDS instance and modify database config file under /etc/mysql/my.cnf
- Create a new parameter group, attach it to DB instance and change the setting
- Create a new option group, attach it to DB instance and change the setting
- Modify setting in default options group attached to DB instance

**Respuesta correcta:** Create a new parameter group, attach it to DB instance and change the setting
**Por qué:** El máximo de conexiones (`max_connections`) es un parámetro de motor gestionado vía DB Parameter Groups. Como los grupos por defecto no se pueden modificar, hay que crear uno nuevo, ajustar el parámetro y asociarlo a la instancia. RDS es un servicio administrado sin acceso SSH al SO (descarta la opción de editar `my.cnf` directamente); los Option Groups habilitan funcionalidades del motor (no ajustan parámetros de conexión).

### 2. Which of these features are provided by Amazon Aurora that are not available with other database engines? (4 puntos)
- Aurora DB engine provides a higher throughput for lower cost than MySQL and PostgreSQL engines
- An Aurora DB cluster support autoscaling by increasing resources available to the primary instance
- An Aurora DB cluster support autoscaling by increasing the number of replicas in the cluster
- Aurora DB engine is compatible with MariaDB, MySQL and PostgreSQL
- Aurora MySQL the only engine supporting active-active/multi-master clustering
- Logs of an Aurora DB instance can be exported to CloudWatch Logs

**Respuesta correcta:** Aurora DB engine provides a higher throughput for lower cost than MySQL and PostgreSQL engines; An Aurora DB cluster support autoscaling by increasing the number of replicas in the cluster; Aurora MySQL the only engine supporting active-active/multi-master clustering
**Por qué:** Aurora ofrece hasta 5x el throughput de MySQL estándar y 3x el de PostgreSQL, a menor costo por unidad de rendimiento. Aurora Auto Scaling ajusta el número de réplicas según métricas de CloudWatch. Aurora MySQL soporta multi-master activo-activo, exclusivo suyo. Aurora NO escala automáticamente el tamaño de la instancia primaria (requiere acción manual), NO es compatible con MariaDB (solo MySQL/PostgreSQL), y exportar logs a CloudWatch no es exclusivo de Aurora (todo RDS lo soporta).

### 3. Media sharing platform: security (encrypted at rest), scalability, minimal latency. ¿Qué storage usar?
- Multi-region Aurora DB cluster
- AWS S3
- AWS DynamoDB with DAX
- PostgreSQL on AWS RDS with cross-region read replicas

**Respuesta correcta:** AWS S3
**Por qué:** Una plataforma de medios necesita almacenamiento de objetos, no una base de datos relacional o NoSQL. S3 soporta encriptación server-side nativa, escala prácticamente sin límite, y se integra con CloudFront para baja latencia global. Aurora/PostgreSQL son para datos estructurados/transaccionales; DynamoDB+DAX es clave-valor de acceso rápido, no para archivos binarios grandes.

### 4. Aplicación read-intensive, RDS con alta carga aumenta el tiempo de respuesta. ¿Qué medidas escalan la capa de datos? (2 puntos)
- Create Amazon DB Read Replicas
- Configure the application layer to query the ReadReplicas for query needs
- Use Auto Scaling to scale out and scale in the database tier
- Use SQS to cache the database queries
- Use ElastiCache in front of your Amazon RDS DB to cache common queries

**Respuesta correcta:** Create Amazon DB Read Replicas; Configure the application layer to query the ReadReplicas for query needs
**Por qué:** La solución estándar para read-intensive es crear Read Replicas y redirigir las lecturas hacia ellas desde la app, dejando el primary solo para escrituras — ambas acciones van juntas. RDS no soporta Auto Scaling horizontal como EC2; SQS es un servicio de colas, no de caché; ElastiCache es válido en general pero en este set de opciones limitado, las Read Replicas son la respuesta esperada.

### 5. ¿En cuáles de estos casos de uso se puede usar Redis? (3 puntos)
- In-memory data storage
- Messaging infrastructure (pub/sub)
- Store structured data with a pre-defined schema
- Caching service

**Respuesta correcta:** In-memory data storage; Messaging infrastructure (pub/sub); Caching service
**Por qué:** Redis es por diseño un almacén en memoria (latencia de microsegundos), soporta pub/sub nativamente, y su caso de uso más común es como caché delante de otras bases de datos. Es clave-valor sin schema fijo — no apto para datos estructurados con esquema predefinido y relaciones complejas.

### 6. RDS PostgreSQL en Singapur, se necesita backup con copia asíncrona de datos. ¿Qué habilitar?
- Enable Multi-AZ for the database
- Enable Read Replicas for the database
- Enable Asynchronous replication for the database
- Enable manual backups for the database

**Respuesta correcta:** Enable Read Replicas for the database
**Por qué:** Los Read Replicas usan replicación asíncrona hacia una copia de solo lectura, cumpliendo exactamente el requisito. Multi-AZ usa replicación síncrona para failover (no es "copia asíncrona"); "Enable Asynchronous replication" no es una opción real/configurable en RDS; los backups manuales son snapshots puntuales, no una réplica continua.

### 7. Si tienes varias Read Replicas y promueves una, ¿qué pasa con las demás?
- The remaining Read Replicas will still replicate from the older master DB Instance
- The remaining Read Replicas will be deleted
- The remaining Read Replicas will be combined to one read replica

**Respuesta correcta:** The remaining Read Replicas will still replicate from the older master DB Instance
**Por qué:** Promover una réplica la convierte en instancia primaria independiente, pero solo afecta a esa réplica — las demás siguen replicando del master original. No se eliminan ni se combinan (no existe tal operación).

### 8. Storage para red social con streaming de eventos sin código/software adicional. (2 puntos)
- PostgreSQL on AWS RDS with logical replication enabled
- Aurora DB cluster
- DynamoDB
- ElastiCache Redis

**Respuesta correcta:** Aurora DB cluster; DynamoDB
**Por qué:** DynamoDB Streams captura cambios a nivel de item automáticamente, sin código adicional. Aurora ofrece Kinesis Data Streams for Aurora, integración nativa sin herramientas de CDC externas. La replicación lógica de PostgreSQL no transmite eventos por sí sola (requeriría DMS/Debezium); ElastiCache Redis requiere código explícito de pub/sub en la app.

### 9. ¿Qué pasa en un deployment Multi-AZ de RDS si falla la instancia primaria?
- IP of the primary DB Instance is switched to the standby DB Instance
- A new DB instance is created in the standby availability zone
- The RDS DB instance reboots
- The canonical name record (CNAME) is changed from primary to standby

**Respuesta correcta:** The canonical name record (CNAME) is changed from primary to standby
**Por qué:** El failover actualiza el endpoint DNS (CNAME) para apuntar a la standby, permitiendo continuidad transparente. La IP no se mueve (cada instancia tiene la suya); la standby ya existe de antemano (no se crea en el momento del fallo); no es un simple reboot, es un cambio de instancia activa + actualización DNS.

### 10. ¿Qué feature NO soporta RDS como plataforma de BD administrada?
- Automated backup
- Automated scaling to manage a higher load
- Automated failure detection and recovery
- Automated software patching

**Respuesta correcta:** Automated scaling to manage a higher load
**Por qué:** RDS no soporta autoscaling automático de cómputo (a diferencia de EC2 Auto Scaling Groups) — escalar verticalmente requiere acción manual. Sí soporta backups automáticos, Multi-AZ (detección de fallos y failover automático), y parcheo automático del motor/SO.

### 11. ¿Cuáles son características de una Read Replica? (4 puntos)
- Can serve legitimate traffic
- Can not be used for disaster recovery
- Helpful with disaster recovery
- Receives the offloaded work of master database
- Cannot be promoted to stand-alone database instances
- Cannot serve legitimate traffic
- Can be promoted to a stand-alone database instance

**Respuesta correcta:** Can serve legitimate traffic; Helpful with disaster recovery; Receives the offloaded work of master database; Can be promoted to a stand-alone database instance
**Por qué:** Una Read Replica atiende consultas de lectura reales, ayuda con DR (especialmente cross-region), descarga tráfico de lectura del master, y puede promoverse a instancia independiente. Las opciones negadas (no sirve para DR, no atiende tráfico, no se puede promover) contradicen directamente estas características reales.

### 12. ¿Qué afirmaciones describen correctamente una base de datos NoSQL? (3 puntos)
- Requires a well-defined schema, where data is normalized into tables, rows, and columns
- Data is organized as documents or key-value pairs and doesn't have a rigid schema
- SQL is used for querying data
- Fits well for use cases when data structure is dynamic
- Generally is easier and cheaper to scale

**Respuesta correcta:** Data is organized as documents or key-value pairs and doesn't have a rigid schema; Fits well for use cases when data structure is dynamic; Generally is easier and cheaper to scale
**Por qué:** Es la característica definitoria de NoSQL: datos sin schema rígido, ideal para estructuras dinámicas, y diseñado para escalado horizontal fácil/barato. "Requiere schema bien definido" describe justo lo opuesto (relacional/SQL); "se usa SQL para consultar" es falso por definición (NoSQL = "Not only SQL", usa APIs propias).

### 13. Load testing: RDS MySQL al 100% CPU, app read-heavy no responde. ¿Qué métodos escalan la capa de datos? (3 puntos)
- Add Amazon RDS DB Read Replicas, and have your application direct read queries to them
- Add your Amazon RDS DB Instance to an Auto Scaling group and configure your CloudWatch metric based on CPU utilization
- Shard your data set among multiple Amazon RDS DB Instances
- Use ElastiCache in front of your Amazon RDS DB to cache common queries

**Respuesta correcta:** Add Amazon RDS DB Read Replicas...; Shard your data set among multiple Amazon RDS DB Instances; Use ElastiCache in front of your Amazon RDS DB to cache common queries
**Por qué:** Read Replicas distribuyen las lecturas reduciendo carga de CPU en el primary; el sharding divide el dataset entre múltiples instancias; ElastiCache cachea las consultas comunes reduciendo las que llegan a RDS. RDS no soporta Auto Scaling Groups como EC2 — no existe esa funcionalidad.

### 14. App con EC2 + RDS. ¿Qué asegura alta disponibilidad en la capa de base de datos?
- Create another EC2 Instance in another Availability Zone and host a replica of the database
- Create another EC2 Instance in another Availability Zone and host a replica of the Webserver
- Enable Read Replica for the AWS RDS database
- Enable Multi-AZ for the AWS RDS database

**Respuesta correcta:** Enable Multi-AZ for the AWS RDS database
**Por qué:** Alta disponibilidad implica tolerar fallos con failover automático y mínimo downtime — exactamente lo que ofrece Multi-AZ (standby síncrona + failover automático). Una réplica manual en EC2 sería una solución casera sin aprovechar capacidades nativas; replicar el web server no aborda la capa de datos; Read Replicas requieren promoción manual, no dan HA automática.

### 15. ¿Cómo aumentar los núcleos de CPU de una instancia DynamoDB?
- Create a new parameter group, increase "cpu_cores" parameter and attach it to the DB
- Modify the instance and choose a different instance class
- It's not possible because DynamoDB is a NoSQL database
- It's not possible because DynamoDB is a SaaS product

**Respuesta correcta:** It's not possible because DynamoDB is a NoSQL database
**Por qué:** DynamoDB es un servicio totalmente administrado y serverless — no expone instancias, clases de instancia, ni recursos de CPU/RAM subyacentes; solo se aprovisiona capacidad en RCU/WCU o modo On-Demand. Los parameter groups son concepto de RDS, no de DynamoDB; clasificarlo como "SaaS" es impreciso (es NoSQL serverless administrado).

### 16. ¿Se puede crear una Read Replica de otra Read Replica?
- Only in certain regions
- Only with MySQL based RDS
- Only for Oracle RDS types
- No

**Respuesta correcta:** Only with MySQL based RDS
**Por qué (con matiz):** Según la documentación de AWS, sí es posible crear cascading read replicas, soportado en MySQL, MariaDB y PostgreSQL (14.1+) — MySQL fue el motor original donde se soportó, por eso es la opción más cercana entre las disponibles. No depende de la región; Oracle no lo soporta de la misma manera. *Nota: si el material de estudio marca "No" como respuesta, puede basarse en documentación desactualizada — conviene verificar con el instructor la clave oficial.*

### 17. ¿Cuál de estas prácticas de configuración/despliegue es un riesgo de seguridad para RDS?
- Storing SQL function code in plaintext
- Non-Multi-AZ RDS instance
- Having RDS and EC2 instances exist in the same subnet
- RDS in a public subnet

**Respuesta correcta:** RDS in a public subnet
**Por qué:** Colocar RDS en una subnet pública (con ruta a un Internet Gateway) expone la base de datos a conexiones directas desde internet. Guardar código SQL en texto plano no es una práctica de infraestructura de RDS; no tener Multi-AZ es riesgo de disponibilidad, no de seguridad; compartir subnet privada entre EC2 y RDS es válido si el acceso está bien controlado con Security Groups.

### 18. ¿Qué aplica a ElastiCache Redis pero NO a Memcached?
- Provides data partitioning capabilities
- Supports complex data structures, such as lists, sets, hashes, etc.
- Has multithreaded architecture
- Is a disk-based database rather than in-memory storage

**Respuesta correcta:** Supports complex data structures, such as lists, sets, hashes, etc.
**Por qué:** Redis soporta tipos avanzados (strings, lists, sets, sorted sets, hashes, streams, bitmaps); Memcached solo un modelo básico clave-valor con strings/blobs planos. El particionado de datos aplica a ambos; la arquitectura multithreaded describe a Memcached (Redis es tradicionalmente single-threaded); ambos son almacenes en memoria (Redis solo añade persistencia opcional a disco).
