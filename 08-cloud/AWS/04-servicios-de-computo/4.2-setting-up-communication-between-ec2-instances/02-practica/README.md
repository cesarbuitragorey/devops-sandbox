# Práctica — Setting Up Communication between EC2 Instances

## Enunciado de la tarea

> Set up proper security group configurations and allow instances to reach each other via TCP port 80 and the ICMP protocol.

**Región:** `eu-west-1`

**Recursos de la tarea:**
- VPC `cmtr-iacp1ebx-ec2-sg-vpc`
- EC2 `cmtr-iacp1ebx-ec2-sg-instance-public1` (subred pública) y `cmtr-iacp1ebx-ec2-sg-instance-private1` (subred privada)
- Security Groups `cmtr-iacp1ebx-ec2-sg-sg-public1_sg` y `cmtr-iacp1ebx-ec2-sg-sg-private1_sg`
- SG de Session Manager `cmtr-iacp1ebx-ec2-sg-sg-session-manager-connectivity` — **no tocar**

**Objetivo (4 movimientos):** tráfico bidireccional de HTTP (puerto 80) e ICMP entre ambos Security Groups.

**Nota:** este lab lo resolví directamente en la plataforma. Documento el flujo de comandos de referencia y, en `03-resultados`, los datos reales confirmados por el "Check".

---

## Obtener los IDs de los Security Groups

```bash
SG_PUBLIC_ID=$(aws ec2 describe-security-groups --region eu-west-1 --filters Name=group-name,Values=cmtr-iacp1ebx-ec2-sg-sg-public1_sg --query 'SecurityGroups[0].GroupId' --output text)
SG_PRIVATE_ID=$(aws ec2 describe-security-groups --region eu-west-1 --filters Name=group-name,Values=cmtr-iacp1ebx-ec2-sg-sg-private1_sg --query 'SecurityGroups[0].GroupId' --output text)
```

## Movimientos 1-2 — Reglas en el Security Group privado (origen: público)

```bash
aws ec2 authorize-security-group-ingress \
  --group-id $SG_PRIVATE_ID \
  --protocol tcp --port 80 \
  --source-group $SG_PUBLIC_ID \
  --region eu-west-1

aws ec2 authorize-security-group-ingress \
  --group-id $SG_PRIVATE_ID \
  --protocol icmp --port -1 \
  --source-group $SG_PUBLIC_ID \
  --region eu-west-1
```

## Movimientos 3-4 — Reglas en el Security Group público (origen: privado)

```bash
aws ec2 authorize-security-group-ingress \
  --group-id $SG_PUBLIC_ID \
  --protocol tcp --port 80 \
  --source-group $SG_PRIVATE_ID \
  --region eu-west-1

aws ec2 authorize-security-group-ingress \
  --group-id $SG_PUBLIC_ID \
  --protocol icmp --port -1 \
  --source-group $SG_PRIVATE_ID \
  --region eu-west-1
```

## Verificación — conectarse por Session Manager y probar en ambas direcciones

```bash
aws ssm start-session --target <instance-id-public1> --region eu-west-1
# dentro:
ping -c 1 <IP_PRIVADA_DE_PRIVATE1>
curl <IP_PRIVADA_DE_PRIVATE1>
```
Repetir en sentido inverso desde la instancia privada hacia la pública.
