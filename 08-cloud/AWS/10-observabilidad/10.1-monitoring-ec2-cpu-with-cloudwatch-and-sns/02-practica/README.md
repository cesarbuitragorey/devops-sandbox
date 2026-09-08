# Práctica — Monitoring EC2 CPU with CloudWatch and SNS for Notification

## Enunciado de la tarea

> Launch an EC2 instance that runs a CPU-stress script for 30 minutes, and configure a CloudWatch alarm on CPUUtilization (≥60%) that notifies an SNS topic (email subscription).

**Región:** `eu-west-1` — Cuenta `980921730449`

**Infraestructura pre-creada:** VPC `cmtr-iacp1ebx-vpc` (`vpc-0a073803b9928739a`) con 2 subnets públicas (`subnet-0074987b315b19b6b`/eu-west-1b, `subnet-09bbf3baf72406a0d`/eu-west-1a).

**Entorno real usado:** CLI local (Git Bash).

---

## Movimiento 1 — Security Group + AMI

```bash
SG_ID=$(aws ec2 create-security-group --group-name cmtr-iacp1ebx-sg --description "Allow SSH access" --vpc-id vpc-0a073803b9928739a --query 'GroupId' --output text)
aws ec2 authorize-security-group-ingress --group-id $SG_ID --protocol tcp --port 22 --cidr 0.0.0.0/0

MSYS_NO_PATHCONV=1 aws ssm get-parameters --names /aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64 --query 'Parameters[0].Value' --output text --region eu-west-1
```

### Incidente: Git Bash reescribe rutas tipo `/aws/...`

```
"InvalidParameters": ["C:/Program Files/Git/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"]
```
Git Bash (MSYS2) convierte automáticamente argumentos que parecen rutas Unix absolutas en rutas de Windows. **Fix**: prefijar el comando con `MSYS_NO_PATHCONV=1`.

## Movimiento 2 — Instancia EC2 con UserData

```bash
cat > userdata.sh << 'EOF'
#!/bin/bash
sudo dnf install -y stress
sudo stress --cpu 2 --timeout 1800s &
EOF

aws ec2 run-instances \
  --image-id ami-00b98fcf187a433fa \
  --instance-type t3.micro \
  --subnet-id subnet-09bbf3baf72406a0d \
  --security-group-ids $SG_ID \
  --associate-public-ip-address \
  --user-data file://userdata.sh \
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=cmtr-iacp1ebx-instance}]'
```

## Movimiento 3 — SNS topic + suscripción de email

```bash
TOPIC_ARN=$(aws sns create-topic --name cmtr-iacp1ebx-sns --query 'TopicArn' --output text --region eu-west-1)
aws sns subscribe --topic-arn $TOPIC_ARN --protocol email --notification-endpoint cesar_buitrago@epam.com --region eu-west-1
# Confirmado haciendo clic en el link recibido por correo
```

## Movimiento 4 — Alarma de CloudWatch

```bash
aws cloudwatch put-metric-alarm \
  --alarm-name cmtr-iacp1ebx-alarm \
  --metric-name CPUUtilization --namespace AWS/EC2 --statistic Average \
  --period 300 --threshold 60 --comparison-operator GreaterThanOrEqualToThreshold \
  --evaluation-periods 1 \
  --dimensions Name=InstanceId,Value=<instance-id> \
  --alarm-actions $TOPIC_ARN \
  --region eu-west-1
```

## Incidentes descubiertos vía checks de la plataforma

1. **UserData sin `sudo` explícito** — el checker validaba el contenido textual del script contra el patrón `sudo dnf install .*stress.*`; el script original (`dnf install -y stress`, sin `sudo`) funcionaba pero no matcheaba el regex. Como UserData no se puede reeditar en caliente, se **terminó la instancia original y se relanzó** con el script corregido (`sudo dnf install...`), actualizando el `Dimensions` de la alarma al nuevo `InstanceId`.
2. **`ComparisonOperator` incorrecto** — se creó inicialmente con `GreaterThanThreshold` (según la lectura literal del enunciado, "greater than"), pero el checker exigía `GreaterThanOrEqualToThreshold`. Se corrigió con un nuevo `put-metric-alarm` (idempotente, misma alarma).

## Verificación

Tras los ajustes, los 9 checks de la plataforma pasaron, incluyendo la confirmación de la suscripción por email y los parámetros exactos de la alarma.
