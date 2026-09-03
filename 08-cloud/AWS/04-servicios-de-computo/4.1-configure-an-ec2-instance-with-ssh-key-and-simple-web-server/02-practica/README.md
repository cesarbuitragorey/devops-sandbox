# Práctica — Configure an EC2 Instance with SSH Key and Simple Web Server

## Enunciado de la tarea

> Create an EC2 instance, with an SSH key attached and a simple web server deployed.

**Región:** `eu-west-1`

**Recursos de la tarea:**
- VPC `cmtr-iacp1ebx-vpc` (ya provisionada)
- IAM Role / Instance Profile `cmtr-iacp1ebx-role` con `CloudWatchAgentServerPolicy`
- Security Group `cmtr-iacp1ebx-sg` (puerto 80 desde cualquier origen, puerto 22 desde el IP propio)
- SSH Key Pair `cmtr-iacp1ebx-key`
- EC2 Instance `cmtr-iacp1ebx-instance` (`t3.micro`, Amazon Linux 2023) con Apache (`httpd`)

**Nota:** este lab lo resolví directamente en la plataforma sin pasar por esta sesión, así que abajo documento el flujo de comandos de referencia (equivalente a lo que se necesita para cada objetivo), y en `03-resultados` quedan los datos reales confirmados por el "Check" de la plataforma.

---

## Movimiento 1 — Rol + Instance Profile

```bash
aws iam create-role \
  --role-name cmtr-iacp1ebx-role \
  --assume-role-policy-document '{"Version":"2012-10-17","Statement":[{"Effect":"Allow","Principal":{"Service":"ec2.amazonaws.com"},"Action":"sts:AssumeRole"}]}'

aws iam attach-role-policy \
  --role-name cmtr-iacp1ebx-role \
  --policy-arn arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy

aws iam create-instance-profile --instance-profile-name cmtr-iacp1ebx-role
aws iam add-role-to-instance-profile --instance-profile-name cmtr-iacp1ebx-role --role-name cmtr-iacp1ebx-role
```

## Movimiento 2 — Security Group

```bash
VPC_ID=$(aws ec2 describe-vpcs --region eu-west-1 --filters Name=tag:Name,Values=cmtr-iacp1ebx-vpc --query 'Vpcs[0].VpcId' --output text)
MY_IP=$(curl -s https://checkip.amazonaws.com)

SG_ID=$(aws ec2 create-security-group \
  --group-name cmtr-iacp1ebx-sg \
  --description "SG for cmtr-iacp1ebx-instance" \
  --vpc-id $VPC_ID \
  --region eu-west-1 --query 'GroupId' --output text)

aws ec2 authorize-security-group-ingress --group-id $SG_ID --protocol tcp --port 80 --cidr 0.0.0.0/0 --region eu-west-1
aws ec2 authorize-security-group-ingress --group-id $SG_ID --protocol tcp --port 22 --cidr ${MY_IP}/32 --region eu-west-1
```

## Movimiento 3 — SSH Key Pair

```bash
aws ec2 create-key-pair \
  --key-name cmtr-iacp1ebx-key \
  --region eu-west-1 \
  --query 'KeyMaterial' --output text > cmtr-iacp1ebx-key.pem

chmod 400 cmtr-iacp1ebx-key.pem
```
> La clave privada (`.pem`) solo se puede descargar en este momento — guardarla de inmediato en un lugar seguro.

## Movimiento 4 — Lanzar la instancia EC2 (con web server vía user-data)

```bash
SUBNET_ID=$(aws ec2 describe-subnets --region eu-west-1 --filters Name=vpc-id,Values=$VPC_ID --query 'Subnets[0].SubnetId' --output text)

AMI_ID=$(aws ssm get-parameters \
  --names /aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64 \
  --region eu-west-1 --query 'Parameters[0].Value' --output text)

cat > httpd-userdata.sh << 'EOF'
#!/bin/bash
dnf install -y httpd
systemctl enable httpd
systemctl start httpd
EOF

aws ec2 run-instances \
  --image-id $AMI_ID \
  --instance-type t3.micro \
  --key-name cmtr-iacp1ebx-key \
  --subnet-id $SUBNET_ID \
  --security-group-ids $SG_ID \
  --iam-instance-profile Name=cmtr-iacp1ebx-role \
  --associate-public-ip-address \
  --user-data file://httpd-userdata.sh \
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=cmtr-iacp1ebx-instance}]' \
  --region eu-west-1
```

## Verificación

```bash
PUBLIC_IP=$(aws ec2 describe-instances --region eu-west-1 --filters Name=tag:Name,Values=cmtr-iacp1ebx-instance --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)

# Por SSH
ssh -i cmtr-iacp1ebx-key.pem ec2-user@$PUBLIC_IP

# Por HTTP
curl -I http://$PUBLIC_IP
```
Se espera `HTTP/1.1 200 OK` y `Content-Type: text/html` en la respuesta.
