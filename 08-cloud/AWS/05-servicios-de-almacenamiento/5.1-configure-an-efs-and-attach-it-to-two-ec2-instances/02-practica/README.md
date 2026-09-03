# Práctica — Configure an EFS and Attach It to Two EC2 Instances

## Enunciado de la tarea

> Create an EFS file system and attach it to two EC2 instances located in different Availability Zones.

**Región:** `eu-west-1` — Cuenta `445567101831`

**Recursos de la tarea:**
- VPC `cmtr-iacp1ebx-vpc` (ya provisionada, con subredes públicas/privadas en `eu-west-1a` y `eu-west-1b`)
- IAM Role `cmtr-iacp1ebx-role` con `AmazonSSMManagedInstanceCore`
- Security Groups `cmtr-iacp1ebx-ec2-sg` y `cmtr-iacp1ebx-efs-sg`
- EFS `cmtr-iacp1ebx-efs`
- EC2 `cmtr-iacp1ebx-instance1` (eu-west-1a) y `cmtr-iacp1ebx-instance2` (eu-west-1b)

**Entorno real usado:** sandbox AWS, trabajado por **CLI** en CloudShell.

---

## Fase 0 — Descubrir VPC y subredes públicas por AZ

```bash
export AWS_PAGER=""
VPC_ID=$(aws ec2 describe-vpcs --region eu-west-1 --filters Name=tag:Name,Values=cmtr-iacp1ebx-vpc --query 'Vpcs[0].VpcId' --output text)

aws ec2 describe-subnets --region eu-west-1 --filters Name=vpc-id,Values=$VPC_ID \
  --query 'Subnets[*].[SubnetId,AvailabilityZone,MapPublicIpOnLaunch,Tags[?Key==`Name`].Value|[0]]' --output table
```
Resultado: pública `eu-west-1a` = `subnet-020ddfcb90638e6c6`, pública `eu-west-1b` = `subnet-0b81c826e6ff494b5`.

## Movimiento 1 — Rol + Instance Profile

```bash
aws iam create-role --role-name cmtr-iacp1ebx-role \
  --assume-role-policy-document '{"Version":"2012-10-17","Statement":[{"Effect":"Allow","Principal":{"Service":"ec2.amazonaws.com"},"Action":"sts:AssumeRole"}]}'
aws iam attach-role-policy --role-name cmtr-iacp1ebx-role --policy-arn arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore
aws iam create-instance-profile --instance-profile-name cmtr-iacp1ebx-role
aws iam add-role-to-instance-profile --instance-profile-name cmtr-iacp1ebx-role --role-name cmtr-iacp1ebx-role
sleep 15
```

## Movimientos 2-3 — Security Groups

```bash
SG_EC2_ID=$(aws ec2 create-security-group --group-name cmtr-iacp1ebx-ec2-sg --description "SG for cmtr-iacp1ebx instances" --vpc-id $VPC_ID --region eu-west-1 --query 'GroupId' --output text)

SG_EFS_ID=$(aws ec2 create-security-group --group-name cmtr-iacp1ebx-efs-sg --description "SG for cmtr-iacp1ebx-efs" --vpc-id $VPC_ID --region eu-west-1 --query 'GroupId' --output text)
aws ec2 authorize-security-group-ingress --group-id $SG_EFS_ID --protocol tcp --port 2049 --cidr 10.0.0.0/16 --region eu-west-1
```

## Movimiento 4 — Crear el EFS

```bash
EFS_ID=$(aws efs create-file-system --creation-token cmtr-iacp1ebx-efs --tags Key=Name,Value=cmtr-iacp1ebx-efs --region eu-west-1 --query 'FileSystemId' --output text)
sleep 15
aws efs describe-file-systems --file-system-id $EFS_ID --region eu-west-1 --query 'FileSystems[0].LifeCycleState' --output text
```

## Movimiento 5 — Mount Targets en ambas AZs

```bash
aws efs create-mount-target --file-system-id $EFS_ID --subnet-id subnet-020ddfcb90638e6c6 --security-groups $SG_EFS_ID --region eu-west-1
aws efs create-mount-target --file-system-id $EFS_ID --subnet-id subnet-0b81c826e6ff494b5 --security-groups $SG_EFS_ID --region eu-west-1

sleep 60
aws efs describe-mount-targets --file-system-id $EFS_ID --region eu-west-1 --query 'MountTargets[*].[SubnetId,LifeCycleState,IpAddress]' --output table
```
Resultado final: `subnet-020ddfcb90638e6c6` → `10.0.1.92` (available), `subnet-0b81c826e6ff494b5` → `10.0.3.79` (available).

## Movimientos 6-9 — Lanzar las 2 instancias (con intento de auto-mount vía user-data)

```bash
AMI_ID=$(aws ssm get-parameters --names /aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64 --region eu-west-1 --query 'Parameters[0].Value' --output text)

cat > efs-userdata.sh << EOF
#!/bin/bash
dnf install -y amazon-efs-utils
mkdir -p /mnt/efs
mount -t efs -o tls ${EFS_ID}:/ /mnt/efs
echo "${EFS_ID}:/ /mnt/efs efs _netdev,tls 0 0" >> /etc/fstab
EOF

INSTANCE1_ID=$(aws ec2 run-instances --image-id $AMI_ID --instance-type t3.micro \
  --subnet-id subnet-020ddfcb90638e6c6 --security-group-ids $SG_EC2_ID \
  --iam-instance-profile Name=cmtr-iacp1ebx-role --associate-public-ip-address \
  --user-data file://efs-userdata.sh \
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=cmtr-iacp1ebx-instance1}]' \
  --region eu-west-1 --query 'Instances[0].InstanceId' --output text)

INSTANCE2_ID=$(aws ec2 run-instances --image-id $AMI_ID --instance-type t3.micro \
  --subnet-id subnet-0b81c826e6ff494b5 --security-group-ids $SG_EC2_ID \
  --iam-instance-profile Name=cmtr-iacp1ebx-role --associate-public-ip-address \
  --user-data file://efs-userdata.sh \
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=cmtr-iacp1ebx-instance2}]' \
  --region eu-west-1 --query 'Instances[0].InstanceId' --output text)
```

### Incidente: el auto-mount del user-data falló por resolución DNS

Al conectarse por Session Manager (`aws ssm start-session --target $INSTANCE1_ID --region eu-west-1`) y correr `df -h | grep efs`, no aparecía ningún montaje. El log de arranque lo confirmó:
```bash
sudo tail -50 /var/log/cloud-init-output.log
```
```
Failed to resolve "fs-0119f8e1c5d26168d.efs.eu-west-1.amazonaws.com" - check that your file system ID is correct...
Attempting to lookup mount target ip address using botocore. Failed to import necessary dependency botocore, please install botocore first.
```

Un `nslookup` manual del nombre confirmó `NXDOMAIN`, a pesar de que `enableDnsSupport` de la VPC estaba en `true` (`enableDnsHostnames` en `false`, lo cual no afecta a este mecanismo). Reintentar el `mount -t efs` manualmente después de confirmar los mount targets `available` dio el mismo error — no era un problema de timing, sino de resolución DNS específica de este sandbox.

**Fix**: montar directamente por la IP del mount target de la AZ correspondiente, usando el cliente NFS4 estándar en vez del helper de EFS:
```bash
# En instance1 (eu-west-1a)
sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport 10.0.1.92:/ /mnt/efs

# En instance2 (eu-west-1b)
sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport 10.0.3.79:/ /mnt/efs
```
Ambos montajes confirmados con `df -h | grep efs` → `10.0.X.XX:/ nfs4 8.0E 0 8.0E 0% /mnt/efs`.

## Movimientos 10-11 — Crear y verificar el archivo compartido

En `instance1`:
```bash
echo "Hello, World!" | sudo tee /mnt/efs/test-file.txt
cat /mnt/efs/test-file.txt
```

En `instance2` (tras montar):
```bash
cat /mnt/efs/test-file.txt
# Hello, World!
```
Confirmado: el mismo archivo, mismo contenido, visible desde ambas instancias en AZs distintas.
