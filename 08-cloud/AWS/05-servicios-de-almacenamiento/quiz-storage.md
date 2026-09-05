# Quiz de DevOps Bootcamp — AWS Storage

Preguntas, respuestas correctas y explicaciones. Material de repaso para el módulo 5 (Servicios de Almacenamiento).

---

### 1. ¿Cuáles son clases de almacenamiento de EFS? (4 puntos)
- EFS Standard
- EFS One Zone
- EFS Standard-IA
- EFS One Zone-IA
- EFS Intelligent-Tiering
- EFS Regional-IA

**Respuesta correcta:** EFS Standard; EFS Standard-IA; EFS One Zone; EFS One Zone-IA
**Por qué:** EFS tiene exactamente 4 clases de almacenamiento: Standard, Standard-IA, One Zone y One Zone-IA. "Intelligent-Tiering" y "Regional-IA" no existen en EFS (Intelligent-Tiering es de S3).

### 2. Tu aplicación guarda logs en un bucket S3 por un período temporal, tras el cual pueden borrarse. ¿Qué usar para gestionar esto eficientemente?
- Crear un cron job para borrar logs viejos
- Usar una IAM Policy para gestionar el borrado
- Usar S3 Lifecycle Policies
- Usar una bucket policy para gestionar el borrado

**Respuesta correcta:** Usar S3 Lifecycle Policies
**Por qué:** Las S3 Lifecycle Policies automatizan la expiración/eliminación de objetos tras un número de días, sin infraestructura adicional.

### 3. Elegir las afirmaciones VERDADERAS para Amazon S3 Bucket (4 puntos)
- Los buckets deben tener un nombre globalmente único
- Los buckets se definen a nivel de AZ
- El nombre del bucket debe tener hasta 63 caracteres
- El nombre puede empezar con mayúscula o número
- No se permite guion bajo en el nombre
- Los buckets S3 son específicos de una región
- Puedes usar una dirección IP como nombre de bucket

**Respuesta correcta:** Nombre globalmente único; hasta 63 caracteres; sin guion bajo; específicos de una región
**Por qué:** Los nombres de bucket son globales, entre 3-63 caracteres, sin underscore, en minúsculas, y cada bucket reside en una región específica. No se permite una IP como nombre.

### 4. Elegir las afirmaciones VERDADERAS para EBS (3 puntos)
- Puedes crear volúmenes cifrados AES-256
- Está ubicado en discos físicamente conectados al host
- El volumen y la instancia deben estar en la misma AZ
- El volumen y la instancia deben estar en la misma VPC
- No es soportado en instancias Windows
- Es una fuente de datos común para cargas en múltiples instancias
- Solo puede usarse como volumen raíz
- Es un servicio de almacenamiento a nivel de bloque

**Respuesta correcta:** Cifrado AES-256; volumen e instancia en la misma AZ; block level storage
**Por qué:** EBS soporta cifrado AES-256, requiere estar en la misma AZ que la instancia, y es un servicio de block storage (no está físicamente conectado al host como Instance Store, ni restringido a la misma VPC, ni exclusivo de root volume, ni compartible entre instancias por defecto).

### 5. ¿Qué tipos de volumen EBS conoces?
- General Purpose (SSD) - gp2
- Provisioned IOPS (SSD) - io1
- Throughput Optimised (HDD) - st1
- Cold (HDD) - sc1
- Warm (HDD) - sw1
- General Purpose (SSD) - gp3
- General Purpose (SSD) - gp5

**Respuesta correcta:** gp2; io1; st1; sc1; gp3
**Por qué:** Son los tipos reales de volumen EBS. "Warm (HDD) - sw1" y "gp5" no existen.

### 6. App de BI que lee datos de una base PostgreSQL en una instancia EC2 standalone, con alto número de lecturas/escrituras. ¿Qué tipo de volumen EBS usar?
- EBS Throughput Optimized HDD
- EBS General Purpose SSD
- EBS Provisioned IOPS SSD
- EBS Cold HDD

**Respuesta correcta:** EBS Provisioned IOPS SSD
**Por qué:** Una BD transaccional con alto I/O requiere IOPS altas y garantizadas, que ofrece Provisioned IOPS SSD (io1/io2).

### 7. Tu organización almacena datos médicos en S3 y no se pueden borrar ni modificar antes de 5 años. ¿Cómo lograrlo?
- Usar la funcionalidad S3 Object Lock
- Crear una función Lambda que no permita cambiar archivos
- Usar una bucket policy para limitar borrados
- Adjuntar marca NO_DELETE a los archivos vía CLI o consola

**Respuesta correcta:** Usar la funcionalidad S3 Object Lock
**Por qué:** S3 Object Lock ofrece un modelo WORM con retención por tiempo definido, diseñado exactamente para requisitos de cumplimiento como este.

### 8. Usuarios de EE.UU. deben acceder al bucket en us-east-1 y usuarios de EU al bucket en eu-north-1. Ambos buckets deben tener los mismos archivos, originados en us-east-1. ¿Cómo lograrlo?
- Habilitar replicación "two-way" entre ambos buckets
- Habilitar S3 Cross-Region Replication entre ambos buckets
- Configurar un job de CodeBuild para copiar archivos cada hora
- Usar una función Lambda para copiar archivos por trigger

**Respuesta correcta:** Habilitar S3 Cross-Region Replication entre ambos buckets
**Por qué:** CRR es la funcionalidad nativa de S3 para replicar automáticamente archivos de un bucket a otro en distinta región, de forma unidireccional.

### 9. Diseñas una solución basada en AWS FSx que debe soportar protocolo NFS, mínima latencia y máximo throughput, y deduplicación de backups. ¿Qué tipo de storage usar?
- Amazon FSx for Lustre
- Amazon FSx for OpenZFS
- Amazon FSx for Windows File Server
- Amazon FSx for NetApp ONTAP

**Respuesta correcta:** Amazon FSx for OpenZFS
**Por qué:** FSx for OpenZFS soporta NFS, ofrece baja latencia/alto throughput, y deduplicación nativa gracias a ZFS.

### 10. Tienes varios volúmenes EBS y necesitas clonarlos a otra región. ¿Cómo lograrlo?
- Copiar el volumen EBS a una instancia EC2 en otra región
- Copiar el snapshot a un bucket S3 y habilitar Cross-Region Replication
- Crear el snapshot y copiarlo a la nueva región
- Crear el snapshot directamente en la otra región

**Respuesta correcta:** Crear el snapshot y copiarlo a la nueva región
**Por qué:** Un volumen EBS es un recurso regional; se debe crear un snapshot y usar "Copy Snapshot" hacia la región destino, para luego crear el volumen ahí.

### 11. ¿Se puede modificar un volumen EBS en caliente (sin detach): aumentar tamaño, cambiar tipo, o ajustar rendimiento I/O (para disco io1)?
- No, hay que desconectar el disco primero
- Sí, se puede hacer en caliente

**Respuesta correcta:** Sí, se puede hacer en caliente
**Por qué:** AWS Elastic Volumes permite modificar tamaño, tipo e IOPS de un volumen EBS sin detenerlo ni desconectarlo.

### 12. Archivos en un bucket S3 deben almacenarse de forma económica por mínimo 90 días y restaurarse en horas. ¿Qué clase de S3 usar?
- S3 Glacier Instant Retrieval
- S3 Glacier Flexible Retrieval
- S3 Glacier Deep Archive
- S3 Glacier Intelligent Restore

**Respuesta correcta:** S3 Glacier Flexible Retrieval
**Por qué:** Flexible Retrieval requiere mínimo 90 días y ofrece restauración en horas (Standard) o minutos (Expedited), a bajo costo.

### 13. Vas a migrar a AWS varios servidores de archivos Linux que usan sistema de archivos EXT. ¿Qué tipo de storage FSx usar?
- Amazon FSx for Lustre
- Amazon FSx for OpenZFS
- Amazon FSx for Windows File Server
- Amazon FSx for NetApp ONTAP

**Respuesta correcta:** Amazon FSx for OpenZFS
**Por qué:** FSx for OpenZFS está diseñado para migrar servidores Linux con sistemas de archivos tipo EXT, con compatibilidad nativa NFS.

### 14. Tienes versioning habilitado en un bucket S3 con muchos archivos. Un compañero hace clic en DELETE y borra accidentalmente un archivo. ¿Qué pasará?
- Con versioning habilitado, un DELETE simple no borra permanentemente; S3 inserta un delete marker
- Solo se borró la última versión del objeto
- Todas las versiones del objeto se borraron permanentemente
- Solo se borró la primera versión del objeto

**Respuesta correcta:** Con versioning habilitado, un DELETE simple no borra permanentemente; S3 inserta un delete marker
**Por qué:** Con versioning, un DELETE simple agrega un delete marker; todas las versiones anteriores permanecen y son recuperables.

### 15. ¿Cómo encontrar información sobre el espacio libre de tu volumen EBS?
- Métricas default de EBS en CloudWatch
- AWS CLI
- AWS Agent
- CloudWatch Logs
- CloudWatch Agent

**Respuesta correcta:** CloudWatch Agent
**Por qué:** El espacio libre del sistema de archivos no es visible para AWS a nivel de hipervisor; se necesita el CloudWatch Agent instalado en la instancia para recolectar esa métrica.

### 16. Elegir las afirmaciones VERDADERAS para EC2 Instance Store (5 puntos)
- Mejor rendimiento I/O con muy baja latencia
- EC2 Instance Store pierde su almacenamiento si se detiene o termina
- Se puede desconectar un volumen de instance store de una instancia y conectarlo a otra
- Bueno para buffer/cache/scratch data/contenido temporal
- EC2 Instance Store no pierde su almacenamiento si se hiberna
- Riesgo de pérdida de datos si el hardware falla
- Backups y replicación son tu responsabilidad

**Respuesta correcta:** Mejor I/O y baja latencia; pierde almacenamiento al detener/terminar; bueno para buffer/cache/temporal; riesgo si falla hardware; backups son tu responsabilidad
**Por qué:** El Instance Store ofrece mejor I/O por estar conectado físicamente al host, pero es efímero (se pierde al detener/terminar/hibernar), no se puede mover entre instancias, y requiere que el usuario gestione backups.

### 17. ¿Cuáles son afirmaciones VERDADERAS del tipo de almacenamiento block storage? (2 puntos)
- Datos en volúmenes/bloques de tamaño uniforme, cada bloque con dirección y metadata propia
- Los datos se pueden acceder directamente vía APIs o HTTP/HTTPS
- Datos en bloques con dirección propia pero sin metadata
- El acceso está restringido a un único path
- En block storage, los datos se organizan en archivos y carpetas jerárquicas
- Block storage ofrece mayor eficiencia y rendimiento que file storage
- No hay carpetas ni jerarquías; cada objeto es un repositorio con datos, metadata e ID único

**Respuesta correcta:** Datos en bloques con dirección y metadata propia; mayor eficiencia y rendimiento que file storage
**Por qué:** Block storage divide los datos en bloques direccionables con metadata, ofreciendo mejor rendimiento que file storage. Las demás opciones describen object storage o file storage.

### 18. Quieres cifrar un volumen EBS sin cifrar que está adjunto a tu instancia EC2. ¿Qué hacer?
- Editar atributos del volumen y marcar "Encrypt using KMS"
- Crear un snapshot, copiarlo activando cifrado, y crear un nuevo volumen desde ese snapshot cifrado
- Crear un volumen cifrado nuevo y copiar los datos manualmente
- Pedir a AWS Support que cifre el volumen

**Respuesta correcta:** Crear un snapshot, copiarlo activando cifrado, y crear un nuevo volumen desde ese snapshot cifrado
**Por qué:** El cifrado no puede activarse directamente sobre un volumen existente; el proceso oficial es snapshot → copy snapshot (cifrado) → crear nuevo volumen desde ese snapshot.

### 19. Debes restringir archivos de la tienda "Kitty" almacenados en S3 junto con otros archivos, a un grupo de usuarios. ¿Cómo lograrlo?
- Mover todos los archivos de Kitty a una carpeta y restringir acceso con IAM
- Configurar Object Lock para evitar que otros accedan
- Configurar Lambda para vigilar archivos y bloquear acceso no autorizado
- Usar S3 object tags e IAM policies para dar permisos granulares

**Respuesta correcta:** Usar S3 object tags e IAM policies para dar permisos granulares
**Por qué:** Como los archivos están mezclados con otros, la solución es etiquetar los objetos (S3 tags) y usar IAM policies con condiciones basadas en esos tags para dar acceso granular sin reorganizar archivos.

### 20. ¿Cuál es la definición correcta de Amazon S3?
- Object-level storage para almacenar y recuperar cualquier cantidad de datos desde cualquier lugar, con durabilidad/disponibilidad/rendimiento/seguridad líderes y escalabilidad virtualmente ilimitada a bajo costo. El objeto más grande en un solo PUT es 5GB. Tamaño máximo de objeto: 5TB
- File-level storage para almacenar y recuperar cualquier cantidad de datos desde cualquier lugar, con las mismas características
- Object-level storage para una cantidad LIMITADA de datos, de un mínimo de 0 bytes a un máximo de 5TB
- Object-level storage para una cantidad LIMITADA de datos, de un mínimo de 0 bytes a un máximo de 5GB

**Respuesta correcta:** Object-level storage, cualquier cantidad de datos, PUT máximo 5GB, objeto máximo 5TB
**Por qué:** Es la definición oficial de S3: almacenamiento a nivel de objeto (no archivo), capacidad virtualmente ilimitada, con límite de 5GB por PUT simple y 5TB de tamaño máximo por objeto individual.

### 21. Your client wants to make sure that file encryption is happening in S3, but he wants to fully manage the encryption keys and never store them in AWS. What do you recommend him to use?
- SSE-KMS Encryption
- SSE-S3 Encryption
- Client Side Encryption
- SSE-C Encryption

**Respuesta correcta:** SSE-C Encryption
**Por qué:** El cliente provee su propia clave en cada request; S3 encripta/desencripta en el servidor pero nunca almacena la llave (solo un hash para validarla). Cumple: encriptación en S3 + control total del cliente + llave nunca guardada en AWS. SSE-KMS mantiene la llave dentro de AWS KMS; SSE-S3 la gestiona AWS por completo; Client Side Encryption ocurre fuera de S3, no cumple "encriptación en S3".

### 22. You are running a high-performance application that requires 310.000 IOPS for its cache. What do you recommend to use?
- Use an EBS io1 drive
- Use an EBS gp3 drive
- Use an EC2 Instance Store
- Use an EBS io2 Block Express drive

**Respuesta correcta:** Use an EC2 Instance Store
**Por qué:** Instance Store está físicamente conectado al host (NVMe local), no pasa por la red de EBS, y puede entregar cientos de miles a millones de IOPS — además "cache" indica que los datos no necesitan persistir, aceptable para almacenamiento efímero. io1 tope ~64.000 IOPS, gp3 tope 16.000 IOPS, io2 Block Express tope 256.000 IOPS — todos por debajo de lo requerido.

### 23. You're going to migrate to AWS several Windows File servers that managed by Active Directory. Which type of AWS FSx storage should you use? (Choose 2)
- Amazon FSx for Lustre
- Amazon FSx for OpenZFS
- Amazon FSx for Windows File Server
- Amazon FSx for NetApp ONTAP

**Respuesta correcta:** Amazon FSx for Windows File Server; Amazon FSx for NetApp ONTAP
**Por qué:** Ambas se integran nativamente con Active Directory y soportan SMB. Lustre es para HPC/Linux; OpenZFS es para Linux/Unix vía NFS, sin integración AD.

### 24. You are a bucket owner and grant cross-account permissions to user Bob from another AWS account to upload new objects. What are the TRUE of the following statements in this case?
- Bob will be an owner of those objects that he uploaded
- You will not have permissions on the objects that were uploaded by Bob
- Bob will pay the bills for all new object he uploaded
- You can deny access to any objects, regardless of who uploads them
- You cannot delete those objects that were uploaded by Bob

**Respuesta correcta:** Bob will be an owner of those objects that he uploaded; You can deny access to any objects, regardless of who uploads them
**Por qué:** Quien sube un objeto es su object owner por defecto, sin importar el dueño del bucket. Pero el bucket owner siempre puede usar Bucket Policy para denegar/gestionar acceso (incluido delete), y siempre paga los costos de almacenamiento, sin importar quién subió los objetos.

### 25. What of the following statements about EFS are TRUE? (Choose 5 points)
- Managed NFS (network file system) that can be mounted on many EC2 instances in only one AZ
- EFS is available for EC2 instances within multiple AZ
- Compatible with Linux and Windows
- EFS automatically grows and shrinks as you add and remove files
- Security groups should be used to control NFS traffic
- EFS is more expensive then EBS
- You need to choose the capacity plan before provisioning storage
- EFS Supports encryption at rest and in transit using KMS

**Respuesta correcta:** Disponible en múltiples AZ; crece/decrece automáticamente; Security Groups controlan tráfico NFS; más caro que EBS; soporta cifrado at rest/in transit con KMS
**Por qué:** EFS es regional (multi-AZ), elástico (sin planeación de capacidad previa), controlado por SG en el puerto 2049, generalmente más caro por GB que EBS, y soporta cifrado KMS/TLS. Es compatible solo con Linux (no Windows — para eso existe FSx for Windows), y no requiere elegir un plan de capacidad de antemano.

### 26. You have just terminated an EC2 instance in us-east-1a, and its attached EBS volume is now available. Your teammate tries to attach it to an EC2 instance in us-east-1b but he can't perform this action. What is a possible cause for this?
- He is lacking IAM permissions
- EBS volumes are locked to an AWS Region
- EBS volumes are locked to an Availability Zone
- He cannot use detached volume at all

**Respuesta correcta:** EBS volumes are locked to an Availability Zone
**Por qué:** Un volumen EBS existe físicamente dentro de una AZ específica y solo puede adjuntarse a instancias dentro de esa misma AZ, no a otra AZ aunque estén en la misma región.

### 27. What of the following is NOT an option of S3 Storage Class
- S3 Standard
- S3 Intelligent-Tiering
- S3 Standard-IA
- S3 One Zone-IA
- S3 Glacier
- S3 Glacier Deep Archive
- S3 Outposts
- S3 Regional-IA

**Respuesta correcta:** S3 Regional-IA (no existe)
**Por qué:** Todas las demás son clases reales de S3. "S3 Regional-IA" es un nombre inventado que no existe en el catálogo oficial de AWS.

### 28. When you create an encrypted EBS volume and attach it to a supported instance type what data are encrypted by default? (Choose 2 points)
- Data at rest is encrypted inside the volume
- All the data in flight moving between the instance and the volume is not encrypted
- All snapshots created from the volume are encrypted
- All volumes created from those snapshots are not encrypted

**Respuesta correcta:** Data at rest is encrypted inside the volume; All snapshots created from the volume are encrypted
**Por qué:** Los datos en reposo se cifran automáticamente con KMS, y cualquier snapshot generado hereda ese cifrado. En instancias soportadas, el tráfico in-transit entre instancia y volumen también se cifra, y cualquier volumen nuevo creado desde un snapshot cifrado también hereda el cifrado.

### 29. Do you need to pre-warm EBS volume restored/created from snapshots before use it on production
- Yes, you do. You need to pre-warm by reading all blocks that have data (initialize) to reach maximum performance
- No, you don't. It's ready to be used from the very beginning.

**Respuesta correcta:** Yes, you do (pre-warm requerido)
**Por qué:** Al crear un volumen desde un snapshot, los bloques se almacenan de forma lazy en S3 y se descargan on-demand en la primera lectura, causando latencia adicional. Se recomienda pre-calentar (leer todos los bloques) antes de exponerlo a carga de producción.

### 30. You have a small database on EC2 instance with 200Gb EBS volume attached to it and find out that only 25% capacity of the volume is used. You decided to decrease disk size up to 100Gb. How can you achieve this goal?
- Use Amazon EBS Elastic Volumes
- From the AWS console select the volume you want to change size. For Actions, choose Modify Volume and in the Size field enter a new size of the volume
- Use the AWS CLI with the command: aws ec2 modify-volume --region <regionName> --volume-id <volumeId> --size <newSize>
- You can't straightforward decrease the size of EBS volume. All you can do is create a new smaller volume
- Ask AWS Support to decrease the volume size

**Respuesta correcta:** You can't straightforward decrease the size of EBS volume. All you can do is create a new smaller volume
**Por qué:** Elastic Volumes (y `modify-volume`, por consola o CLI) solo permiten **aumentar** el tamaño de un volumen, nunca reducirlo directamente. El único método soportado es: snapshot → crear un volumen nuevo más pequeño desde ese snapshot → reemplazar el original.

### 31. Choose TRUE statements that describe FSx (Choose 3 points)
- Launch 3rd party high-performance file systems on AWS
- FSx is fully managed by AWS
- Fast HDD storage option
- Only POSIX compliant system support
- Fully managed service
- Encryption is not available
- AWS lets you choose between several widely-used file systems: NetApp ONTAP, OpenZFS, Windows File Server, and Lustre

**Respuesta correcta:** Launch 3rd party high-performance file systems on AWS; Fully managed service; AWS lets you choose entre NetApp ONTAP, OpenZFS, Windows File Server y Lustre
**Por qué:** FSx permite lanzar sistemas de archivos de terceros de la industria, completamente gestionados por AWS (hardware, parches, backups, replicación, detección de fallos), eligiendo entre esas 4 opciones exactas. HDD es la opción económica/lenta (no "fast"), soporta más que solo POSIX (Windows usa NTFS/SMB), y sí soporta cifrado en todas sus variantes.

### 32. You have a 25 GB file that you're trying to upload to S3 but you're getting errors. What is a possible cause for this?
- The file size limit on S3 is 5Gb
- S3 service in your region must be down
- Use Multi-Part upload when you upload files bigger then 5Gb
- You use S3 Glacier Storage class

**Respuesta correcta:** Use Multi-Part upload when you upload files bigger then 5Gb
**Por qué:** El límite de una operación PUT único en S3 es de 5 GB. Para archivos mayores es obligatorio usar Multipart Upload. El límite máximo de un objeto en S3 es 5 TB (no 5GB en general); la storage class no afecta el mecanismo de subida.

### 33. You have a static website that is being hosted on S3 bucket. You got 403(Forbidden) response while trying to reach this site. What is the possible cause?
- The lack of required permissions in IAM policy
- Bucket Encryption is enabled
- Bucket policy doesn't allow public reads
- The bucket is in other region

**Respuesta correcta:** Bucket policy doesn't allow public reads
**Por qué:** Para un sitio web estático público en S3, el bucket debe tener una Bucket Policy que otorgue `s3:GetObject` a todos, además de deshabilitar Block Public Access. Sin ello, cualquier visitante recibe 403. IAM policies controlan usuarios autenticados de la cuenta (no visitantes anónimos); la encriptación no bloquea lecturas HTTP con permiso adecuado; la región no genera errores 403.
