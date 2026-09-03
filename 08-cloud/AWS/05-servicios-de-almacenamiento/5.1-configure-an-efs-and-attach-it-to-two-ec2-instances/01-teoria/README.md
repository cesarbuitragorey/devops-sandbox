# Teoría — Amazon EFS compartido entre múltiples AZs

## EFS vs. EBS

| | EBS | EFS |
|---|---|---|
| Tipo | Bloque (block storage) | Archivos (file storage, protocolo NFS) |
| Adjuntable a | Una sola instancia a la vez (por AZ) | Múltiples instancias simultáneamente, incluso en distintas AZs |
| Escala | Tamaño fijo, hay que redimensionar manualmente | Elástico automático, crece y encoge con el uso |

EFS es la opción natural cuando **varias instancias necesitan leer/escribir el mismo conjunto de archivos al mismo tiempo** — como en este lab, donde un archivo creado desde una instancia debe ser visible instantáneamente desde otra, en una AZ distinta.

## Mount Targets — uno por Availability Zone

Un EFS no se "adjunta" directamente a una instancia como un volumen EBS — en su lugar, se crean **Mount Targets**, uno por cada AZ donde se necesite acceso, cada uno con su propia interfaz de red (ENI) e IP dentro de una subred de esa AZ. Las instancias de esa AZ montan el file system apuntando al mount target local, minimizando la latencia entre AZs. El Security Group del mount target controla el tráfico NFS (puerto **2049/TCP**) — de ahí la regla `Allow 2049 desde 10.0.0.0/16` de este lab, permitiendo que cualquier instancia dentro del rango de la VPC pueda conectarse.

## Resolución de nombres de EFS y el `mount helper`

El comando recomendado por AWS para montar un EFS es `mount -t efs -o tls <fs-id>:/ <mount-point>`, que usa el **EFS mount helper** (paquete `amazon-efs-utils`). Este helper:
1. Resuelve el nombre DNS `<fs-id>.efs.<región>.amazonaws.com` a la IP del mount target más cercano (de la AZ de la instancia).
2. Establece un túnel TLS local (vía `stunnel`) para cifrar el tráfico NFS en tránsito.

Si la resolución DNS falla (por la razón que sea — configuración de DNS de la VPC, resolutores personalizados, etc.), el helper también puede consultar la IP del mount target directamente vía la API de EC2 (usando `botocore`) como respaldo — pero si esa librería tampoco está disponible, el montaje falla por completo, incluso si el file system y el mount target existen y están perfectamente sanos.

## Montaje alternativo: cliente NFS estándar por IP

Cuando el helper de EFS no puede resolver el nombre DNS, existe un camino alternativo documentado por AWS: montar usando el cliente **NFS4 genérico de Linux**, apuntando directamente a la **IP del mount target** en vez del nombre DNS:
```bash
mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport <mount-target-ip>:/ <mount-point>
```
Esto evita por completo la dependencia de DNS, a costa de perder el cifrado TLS automático que sí aplica el helper — aceptable dentro de una VPC donde el tráfico ya está contenido y protegido por Security Groups, como en este lab.

## `df -h` como verificación rápida de un montaje NFS/EFS

El tamaño reportado por `df -h` para un montaje EFS (`8.0E`, es decir, exabytes) no es un error — EFS no tiene un tamaño fijo reservado como un volumen EBS; reporta un límite prácticamente ilimitado porque escala automáticamente según el contenido real almacenado.
