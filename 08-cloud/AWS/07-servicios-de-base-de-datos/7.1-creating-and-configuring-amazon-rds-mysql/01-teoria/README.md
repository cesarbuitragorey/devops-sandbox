# Teoría — Creating and Configuring Amazon RDS MySQL

## RDS como servicio administrado

RDS gestiona el aprovisionamiento, parcheo del motor, backups automáticos y failover (en Multi-AZ) de la base de datos, a cambio de que el usuario no tenga acceso al sistema operativo subyacente de la instancia de base de datos — a diferencia de correr MySQL directamente en una instancia EC2, donde el usuario es responsable de todo el mantenimiento.

## DB Subnet Group

Un DB Subnet Group es una colección de subnets (típicamente privadas, en al menos 2 AZs distintas) donde RDS puede colocar la instancia de base de datos y sus réplicas. En este lab, el subnet group (`...-privatedbsubnetgroup-...`) ya venía creado por el stack base del sandbox, con subnets privadas — de ahí que la instancia RDS resultante tenga `PubliclyAccessible: false` por diseño de red, independientemente del flag `--publicly-accessible` que se pase explícitamente.

## Aislamiento de capas vía Security Groups referenciándose entre sí

En vez de abrir el puerto 3306 a un rango CIDR, la regla de ingreso del SG de RDS referencia directamente el **security group** de la capa EC2 (`--source-group`). Esto crea una relación de confianza dinámica: cualquier instancia que en el futuro se asocie a ese SG de EC2 automáticamente hereda acceso a la base de datos, sin tener que editar la regla de RDS cada vez — patrón estándar para arquitecturas de 2 capas (app + datos) en AWS.

## Cifrado de almacenamiento (`StorageEncrypted`)

RDS puede cifrar el almacenamiento subyacente (EBS) de la instancia con una clave de KMS, de forma transparente para la aplicación. Este lab pidió explícitamente **desactivarlo** (`--no-storage-encrypted`) — una elección deliberada del enunciado, no una recomendación general; en un entorno productivo real casi siempre se dejaría habilitado.

## Cliente MySQL en Amazon Linux 2023

AL2023 no incluye el paquete `mysql` tradicional; el cliente se instala vía `mariadb105` (o versiones más nuevas como `mariadb106`), que provee un binario `mysql` compatible con el protocolo de MySQL — de ahí que el prompt final, aunque haya conectado a un motor `mysql` real en RDS, se identifique como "MariaDB monitor" (es el cliente, no el servidor).
