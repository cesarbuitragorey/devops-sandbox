# Práctica — Create and Configure Your Own VPC

## Enunciado de la tarea

> Create a secure and isolated network within AWS by leveraging various components of AWS VPC, hosting web servers alongside a database server (topología, aunque este lab no llega a levantar una base de datos real).

**Región:** `eu-west-1`

**Recursos a crear (8, todos con tag `Name`):**
- VPC `cmtr-iacp1ebx-vpc` (`10.0.0.0/16`)
- Public Subnet `cmtr-iacp1ebx-public_subnet` (`10.0.1.0/24`)
- Private Subnet `cmtr-iacp1ebx-private_subnet` (`10.0.2.0/24`)
- Internet Gateway `cmtr-iacp1ebx-internet_gateway`
- Route Table pública `cmtr-iacp1ebx-route_public` (ruta `0.0.0.0/0` -> IGW)
- Route Table privada `cmtr-iacp1ebx-route_private` (sin ruta a internet)
- EC2 pública `cmtr-iacp1ebx-public` (t3.micro, Amazon Linux 2023, SG `default`, instance profile SSM, nginx)
- EC2 privada `cmtr-iacp1ebx-private` (t3.micro, Amazon Linux 2023, SG `default`)

**Entorno real usado:** sandbox AWS, cuenta `430118838496`. Trabajé por **CLI** (CloudShell), en una sola sesión de shell continua ya que todos los comandos dependen de IDs generados sobre la marcha (variables de entorno).

---

## Bloque 1 — VPC, subredes, Internet Gateway

```bash
export AWS_PAGER=""

VPC_ID=$(aws ec2 create-vpc \
  --cidr-block 10.0.0.0/16 \
  --tag-specifications 'ResourceType=vpc,Tags=[{Key=Name,Value=cmtr-iacp1ebx-vpc}]' \
  --region eu-west-1 --query 'Vpc.VpcId' --output text)

PUBLIC_SUBNET_ID=$(aws ec2 create-subnet \
  --vpc-id $VPC_ID --cidr-block 10.0.1.0/24 --availability-zone eu-west-1a \
  --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=cmtr-iacp1ebx-public_subnet}]' \
  --region eu-west-1 --query 'Subnet.SubnetId' --output text)

PRIVATE_SUBNET_ID=$(aws ec2 create-subnet \
  --vpc-id $VPC_ID --cidr-block 10.0.2.0/24 --availability-zone eu-west-1a \
  --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=cmtr-iacp1ebx-private_subnet}]' \
  --region eu-west-1 --query 'Subnet.SubnetId' --output text)

IGW_ID=$(aws ec2 create-internet-gateway \
  --tag-specifications 'ResourceType=internet-gateway,Tags=[{Key=Name,Value=cmtr-iacp1ebx-internet_gateway}]' \
  --region eu-west-1 --query 'InternetGateway.InternetGatewayId' --output text)

aws ec2 attach-internet-gateway --vpc-id $VPC_ID --internet-gateway-id $IGW_ID --region eu-west-1
```

Resultado: `VPC vpc-002c26e7c4bc81eac`, `Public Subnet subnet-02c9ec1b2284db303`, `Private Subnet subnet-0cbfeb74e8b6d79df`, `IGW igw-09bef7d23ed7c92b7`.

## Bloque 2 — Route Tables

```bash
PUBLIC_RT_ID=$(aws ec2 create-route-table \
  --vpc-id $VPC_ID \
  --tag-specifications 'ResourceType=route-table,Tags=[{Key=Name,Value=cmtr-iacp1ebx-route_public}]' \
  --region eu-west-1 --query 'RouteTable.RouteTableId' --output text)

aws ec2 create-route --route-table-id $PUBLIC_RT_ID --destination-cidr-block 0.0.0.0/0 --gateway-id $IGW_ID --region eu-west-1
aws ec2 associate-route-table --route-table-id $PUBLIC_RT_ID --subnet-id $PUBLIC_SUBNET_ID --region eu-west-1

PRIVATE_RT_ID=$(aws ec2 create-route-table \
  --vpc-id $VPC_ID \
  --tag-specifications 'ResourceType=route-table,Tags=[{Key=Name,Value=cmtr-iacp1ebx-route_private}]' \
  --region eu-west-1 --query 'RouteTable.RouteTableId' --output text)

aws ec2 associate-route-table --route-table-id $PRIVATE_RT_ID --subnet-id $PRIVATE_SUBNET_ID --region eu-west-1
```

La route table privada **no** recibe ningún `create-route` adicional — solo queda con la ruta `local` que AWS agrega por defecto, cumpliendo "no debe permitir acceso directo a internet" sin necesidad de un `Deny` explícito.

## Bloque 3 — Rol + Instance Profile para Session Manager

```bash
aws iam create-role \
  --role-name cmtr-iacp1ebx-ssm-role \
  --assume-role-policy-document '{"Version":"2012-10-17","Statement":[{"Effect":"Allow","Principal":{"Service":"ec2.amazonaws.com"},"Action":"sts:AssumeRole"}]}'

aws iam attach-role-policy \
  --role-name cmtr-iacp1ebx-ssm-role \
  --policy-arn arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore

aws iam create-instance-profile --instance-profile-name cmtr-iacp1ebx-ssm-instance-profile

aws iam add-role-to-instance-profile \
  --instance-profile-name cmtr-iacp1ebx-ssm-instance-profile \
  --role-name cmtr-iacp1ebx-ssm-role

sleep 15   # margen para la propagación de IAM antes de usar el profile en run-instances
```

## Bloque 4 — AMI de Amazon Linux 2023 y Security Group por defecto

```bash
AMI_ID=$(aws ssm get-parameters \
  --names /aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64 \
  --region eu-west-1 --query 'Parameters[0].Value' --output text)
# ami-01a47a61359451e7d

DEFAULT_SG_ID=$(aws ec2 describe-security-groups \
  --filters Name=vpc-id,Values=$VPC_ID Name=group-name,Values=default \
  --region eu-west-1 --query 'SecurityGroups[0].GroupId' --output text)
# sg-0d40da5ed93555fa7
```

## Bloque 5 — Instancia pública (nginx vía user-data + instance profile SSM)

```bash
cat > nginx-userdata.sh << 'EOF'
#!/bin/bash
dnf install -y nginx
systemctl enable nginx
systemctl start nginx
EOF

PUBLIC_INSTANCE_ID=$(aws ec2 run-instances \
  --image-id $AMI_ID \
  --instance-type t3.micro \
  --subnet-id $PUBLIC_SUBNET_ID \
  --security-group-ids $DEFAULT_SG_ID \
  --iam-instance-profile Name=cmtr-iacp1ebx-ssm-instance-profile \
  --associate-public-ip-address \
  --user-data file://nginx-userdata.sh \
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=cmtr-iacp1ebx-public}]' \
  --region eu-west-1 --query 'Instances[0].InstanceId' --output text)
# i-0cedf46be32cbc9b9
```

## Bloque 6 — Instancia privada (sin IP pública, sin instance profile)

```bash
PRIVATE_INSTANCE_ID=$(aws ec2 run-instances \
  --image-id $AMI_ID \
  --instance-type t3.micro \
  --subnet-id $PRIVATE_SUBNET_ID \
  --security-group-ids $DEFAULT_SG_ID \
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=cmtr-iacp1ebx-private}]' \
  --region eu-west-1 --query 'Instances[0].InstanceId' --output text)
# i-09a7c370b9e5e73ed
```

## Esperar arranque + registro en SSM

```bash
sleep 90
aws ec2 describe-instance-status --instance-ids $PUBLIC_INSTANCE_ID $PRIVATE_INSTANCE_ID --region eu-west-1 \
  --query 'InstanceStatuses[].[InstanceId,InstanceState.Name]' --output table

aws ssm describe-instance-information --region eu-west-1 \
  --query 'InstanceInformationList[].[InstanceId,PingStatus]' --output table
```
Ambas instancias en `running`, la pública en `Online` dentro de SSM (la privada no aparece — no tiene instance profile de SSM, esperado, no la necesitamos).

## Verificación — conectarse por Session Manager

```bash
aws ssm start-session --target $PUBLIC_INSTANCE_ID --region eu-west-1
```

Ya dentro (prompt `sh-5.2$`):
```bash
curl localhost              # confirma nginx sirviendo la página de bienvenida
ping -c 4 8.8.8.8            # confirma salida a internet, 0% packet loss
ping -c 4 10.0.2.230          # confirma conectividad a la instancia privada, 0% packet loss
```

### Truco práctico: consultar datos sin cerrar la sesión SSM

Para obtener el IP privado de la instancia privada (necesario para el segundo `ping`) sin cortar la sesión SSM activa, abrí una **segunda pestaña de CloudShell** (ícono `+`) y corrí ahí:
```bash
aws ec2 describe-instances \
  --instance-ids i-09a7c370b9e5e73ed \
  --region eu-west-1 \
  --query 'Reservations[0].Instances[0].PrivateIpAddress' --output text
# 10.0.2.230
```
Evita tener que salir y volver a entrar a la sesión SSM solo para consultar un dato de otra instancia.
