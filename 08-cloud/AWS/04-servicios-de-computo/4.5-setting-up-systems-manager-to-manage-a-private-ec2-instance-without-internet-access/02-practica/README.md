# Práctica — Setting Up Systems Manager to Manage a Private EC2 Instance

## Enunciado de la tarea

> Connect to an EC2 instance via Session Manager and explore a cloud environment with public and private hosts.

**Región:** `eu-west-1`

**Recursos de la tarea:**
- VPC `cmtr-iacp1ebx-ec2-sms-vpc`
- EC2 pública `cmtr-iacp1ebx-ec2-sms-instance-public` y privada `cmtr-iacp1ebx-ec2-sms-instance-private`
- IAM Role `cmtr-iacp1ebx-ec2-sms-iam_role`

**Objetivo (2 movimientos):** configurar acceso vía Session Manager a la instancia privada.

**Nota:** este lab lo resolví directamente en la plataforma. Documento el flujo de comandos de referencia (el más consistente con el enunciado: la infraestructura de red ya trae los VPC Endpoints necesarios, y lo que falta es del lado de IAM) y, en `03-resultados`, los datos reales confirmados por el "Check".

---

## Diagnóstico — confirmar qué le falta a la instancia privada

```bash
aws ec2 describe-instances \
  --filters Name=tag:Name,Values=cmtr-iacp1ebx-ec2-sms-instance-private \
  --region eu-west-1 \
  --query 'Reservations[0].Instances[0].[InstanceId,IamInstanceProfile]'

aws iam get-role --role-name cmtr-iacp1ebx-ec2-sms-iam_role
aws iam list-attached-role-policies --role-name cmtr-iacp1ebx-ec2-sms-iam_role
```

## Movimiento 1 — Adjuntar `AmazonSSMManagedInstanceCore` al rol

```bash
aws iam attach-role-policy \
  --role-name cmtr-iacp1ebx-ec2-sms-iam_role \
  --policy-arn arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore
```

## Movimiento 2 — Asociar el Instance Profile a la instancia privada

```bash
INSTANCE_ID=$(aws ec2 describe-instances \
  --filters Name=tag:Name,Values=cmtr-iacp1ebx-ec2-sms-instance-private \
  --region eu-west-1 --query 'Reservations[0].Instances[0].InstanceId' --output text)

aws ec2 associate-iam-instance-profile \
  --instance-id $INSTANCE_ID \
  --iam-instance-profile Name=cmtr-iacp1ebx-ec2-sms-iam_role \
  --region eu-west-1
```

> Si el Instance Profile no existiera todavía (a diferencia de solo el rol de IAM), haría falta crearlo primero con `aws iam create-instance-profile` y `aws iam add-role-to-instance-profile`, como en el lab 3.1.

## Esperar propagación (y opcionalmente reiniciar)

```bash
sleep 300   # hasta 5 minutos para que el SSM Agent reconozca el nuevo rol

# Opcional, para acelerar:
aws ec2 reboot-instances --instance-ids $INSTANCE_ID --region eu-west-1
```

## Verificación

```bash
aws ssm start-session --target $INSTANCE_ID --region eu-west-1
```

Dentro de la instancia privada (opcional, para explorar la arquitectura completa):
```bash
ping -c 4 <IP_PRIVADA_DE_LA_INSTANCIA_PUBLICA>
```
