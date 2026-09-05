# Práctica — Creating and Configuring Amazon RDS MySQL

## Enunciado de la tarea

> Create and configure a managed MySQL database server using Amazon RDS and verify functionality by connecting to it from an EC2 instance.

**Región:** `eu-west-1` — Cuenta `043309361731`

**Recursos pre-creados por el stack del sandbox:**
- VPC `cmtr-iacp1ebx-vpc`
- Public Subnet `cmtr-iacp1ebx-public_subnet`
- DB Subnet Group `cmtr-iacp1ebx-rds-vpc-stack-privatedbsubnetgroup-0nsu9wk5wkbl`
- Instance Profile `cmtr-iacp1ebx-ssm_instance_profile`

**Objetivos (recursos a crear):**
1. Security Groups `cmtr-iacp1ebx-ec2_sg` y `cmtr-iacp1ebx-rds_sg`
2. Regla de ingreso 3306 desde el SG de EC2 hacia el SG de RDS
3. Instancia RDS `cmtr-iacp1ebx-rds` (MySQL, sin cifrado, en el subnet group indicado)
4. Instancia EC2 `cmtr-iacp1ebx-ec2` (Amazon Linux 2023, t3.micro, subnet pública, perfil SSM)
5. Cliente MySQL instalado y verificado con conexión real a la base de datos

**Entorno real usado:** AWS CloudShell (disponible en este sandbox, sin bloqueo de SCP).

---

## Movimiento 1 — IDs de VPC y subnet pública

```bash
VPC_ID=$(aws ec2 describe-vpcs --filters "Name=tag:Name,Values=cmtr-iacp1ebx-vpc" --query 'Vpcs[0].VpcId' --output text)
SUBNET_ID=$(aws ec2 describe-subnets --filters "Name=tag:Name,Values=cmtr-iacp1ebx-public_subnet" --query 'Subnets[0].SubnetId' --output text)
```

## Movimiento 2 — Security Groups

```bash
EC2_SG_ID=$(aws ec2 create-security-group \
  --group-name cmtr-iacp1ebx-ec2_sg \
  --description "EC2 security group" \
  --vpc-id $VPC_ID \
  --query 'GroupId' --output text)
aws ec2 create-tags --resources $EC2_SG_ID --tags Key=Name,Value=cmtr-iacp1ebx-ec2_sg

RDS_SG_ID=$(aws ec2 create-security-group \
  --group-name cmtr-iacp1ebx-rds_sg \
  --description "RDS security group" \
  --vpc-id $VPC_ID \
  --query 'GroupId' --output text)
aws ec2 create-tags --resources $RDS_SG_ID --tags Key=Name,Value=cmtr-iacp1ebx-rds_sg

aws ec2 authorize-security-group-ingress \
  --group-id $RDS_SG_ID \
  --protocol tcp --port 3306 \
  --source-group $EC2_SG_ID
```
Nótese: el `--source-group` referencia directamente el security group de EC2 (no un CIDR) — cualquier instancia futura en ese SG hereda acceso automáticamente a la base de datos.

## Movimiento 3 — Instancia RDS

```bash
aws rds create-db-instance \
  --db-instance-identifier cmtr-iacp1ebx-rds \
  --db-instance-class db.t3.micro \
  --engine mysql \
  --master-username admin_iacp1ebx \
  --master-user-password 'Es3#uDshSp4elSHO' \
  --allocated-storage 20 \
  --db-subnet-group-name cmtr-iacp1ebx-rds-vpc-stack-privatedbsubnetgroup-0nsu9wk5wkbl \
  --vpc-security-group-ids $RDS_SG_ID \
  --no-storage-encrypted \
  --no-multi-az \
  --no-publicly-accessible

aws rds wait db-instance-available --db-instance-identifier cmtr-iacp1ebx-rds
RDS_ENDPOINT=$(aws rds describe-db-instances --db-instance-identifier cmtr-iacp1ebx-rds --query 'DBInstances[0].Endpoint.Address' --output text)
```
Tardó unos 8-10 minutos en pasar a `available`. Snapshot manual (paso opcional del enunciado) se omitió, sin impacto en el check.

## Movimiento 4 — Instancia EC2

```bash
AMI_ID=$(aws ssm get-parameters --names /aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64 --query 'Parameters[0].Value' --output text)

INSTANCE_ID=$(aws ec2 run-instances \
  --image-id $AMI_ID \
  --instance-type t3.micro \
  --subnet-id $SUBNET_ID \
  --security-group-ids $EC2_SG_ID \
  --associate-public-ip-address \
  --iam-instance-profile Name=cmtr-iacp1ebx-ssm_instance_profile \
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=cmtr-iacp1ebx-ec2}]' \
  --query 'Instances[0].InstanceId' --output text)

aws ec2 wait instance-status-ok --instance-ids $INSTANCE_ID
```

## Movimiento 5 — Cliente MySQL y verificación (vía Session Manager)

```bash
aws ssm start-session --target $INSTANCE_ID
```
Dentro de la instancia:
```bash
sudo dnf install -y mariadb105
mysql -h $RDS_ENDPOINT -u admin_iacp1ebx -p
```
Contraseña: `Es3#uDshSp4elSHO`. Resultado:
```
Welcome to the MariaDB monitor.  Commands end with ; or \g.
Server version: 8.4.9 Source distribution
MySQL [(none)]>
```
Conexión exitosa — el cliente `mariadb105` (paquete disponible en AL2023, ya que no existe `mysql` tradicional) conecta sin problema al motor MySQL real corriendo en RDS.
