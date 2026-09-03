# Práctica — Configuring EC2 User Data

## Enunciado de la tarea

> Configure the user data for an EC2 instance using a launch template to install Nginx and display `WebServer (${instance_public_ip}) with ID: ${instance_id}` on the site.

**Región:** `eu-west-1`

**Recursos de la tarea:**
- Launch Template `cmtr-iacp1ebx-ec2-us-lt`
- Auto Scaling Group `cmtr-iacp1ebx-ec2-us-asg` (usa la versión `$Default` del template — **no modificar su configuración**)
- EC2 `cmtr-iacp1ebx-ec2-us-instance-webserver` (instancia de ejemplo, se reemplaza al hacer el instance refresh de verificación)

**Objetivo (2 movimientos):**
1. Actualizar el user data en la plantilla de lanzamiento.
2. Asegurar que se use la versión correcta.

**Nota:** este lab lo resolví directamente en la plataforma. Documento el flujo de comandos de referencia y, en `03-resultados`, los datos reales confirmados por el "Check".

---

## Diagnóstico — revisar la plantilla actual

```bash
aws ec2 describe-launch-templates --launch-template-names cmtr-iacp1ebx-ec2-us-lt --region eu-west-1

aws ec2 describe-launch-template-versions \
  --launch-template-name cmtr-iacp1ebx-ec2-us-lt \
  --region eu-west-1 \
  --query 'LaunchTemplateVersions[*].[VersionNumber,DefaultVersion,LaunchTemplateData.ImageId]'
```
El hint del enunciado sugiere revisar el AMI para saber el SO (Amazon Linux → `dnf`, o Ubuntu/Debian → `apt`) y así usar el gestor de paquetes correcto en el user data.

## Movimiento 1 — Nueva versión del Launch Template con el user data corregido

Script de user data (para Amazon Linux 2023, ajustar a `apt` si el AMI fuera Debian/Ubuntu):
```bash
cat > userdata.sh << 'EOF'
#!/bin/bash
dnf install -y nginx
TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
INSTANCE_ID=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/instance-id)
PUBLIC_IP=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/public-ipv4)
echo "WebServer ($PUBLIC_IP) with ID: $INSTANCE_ID" > /usr/share/nginx/html/index.html
systemctl enable nginx
systemctl start nginx
EOF

USER_DATA_B64=$(base64 -w 0 userdata.sh)

aws ec2 create-launch-template-version \
  --launch-template-name cmtr-iacp1ebx-ec2-us-lt \
  --source-version '$Default' \
  --launch-template-data "{\"UserData\":\"$USER_DATA_B64\"}" \
  --region eu-west-1
```
`--source-version '$Default'` clona el resto de la configuración de la versión actual (AMI, tipo de instancia, etc.), cambiando únicamente el `UserData`.

## Movimiento 2 — Marcar la nueva versión como Default

```bash
NEW_VERSION=$(aws ec2 describe-launch-template-versions \
  --launch-template-name cmtr-iacp1ebx-ec2-us-lt \
  --region eu-west-1 \
  --query 'LaunchTemplateVersions[?not_null(VersionNumber)]|[-1].VersionNumber' --output text)

aws ec2 modify-launch-template \
  --launch-template-name cmtr-iacp1ebx-ec2-us-lt \
  --default-version $NEW_VERSION \
  --region eu-west-1
```

## Verificación — Instance Refresh del Auto Scaling Group

```bash
aws autoscaling start-instance-refresh \
  --auto-scaling-group-name cmtr-iacp1ebx-ec2-us-asg \
  --region eu-west-1

aws autoscaling describe-instance-refreshes \
  --auto-scaling-group-name cmtr-iacp1ebx-ec2-us-asg \
  --region eu-west-1 --query 'InstanceRefreshes[0].Status'
```

Al completarse el refresh, la instancia de ejemplo (`cmtr-iacp1ebx-ec2-us-instance-webserver`) se reemplaza por una nueva con el user data actualizado:
```bash
curl -I http://<PUBLIC_IP_NUEVA_INSTANCIA>
curl http://<PUBLIC_IP_NUEVA_INSTANCIA>
```
