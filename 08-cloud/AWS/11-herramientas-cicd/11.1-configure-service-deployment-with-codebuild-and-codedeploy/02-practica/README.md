# Práctica — Configure Service Deployment with CodeBuild and CodeDeploy

## Enunciado de la tarea

> Build a Docker image (Alpine + httpd) via CodeBuild and push it to ECR, then deploy it to an EC2 instance via CodeDeploy (in-place deployment).

**Región:** `eu-west-1` — Cuenta `911167900226`

**Entorno real usado:** CLI local (Git Bash).

---

## Movimiento 1 — ECR, rol de CodeBuild, bucket S3

```bash
aws ecr create-repository --repository-name cmtr-iacp1ebx --region eu-west-1

aws iam create-role --role-name cmtr-iacp1ebx-cb --assume-role-policy-document file://cb-trust-policy.json  # trust: codebuild.amazonaws.com
aws iam attach-role-policy --role-name cmtr-iacp1ebx-cb --policy-arn arn:aws:iam::aws:policy/AdministratorAccess

aws s3api create-bucket --bucket cmtr-iacp1ebx-bucket-13120 --region eu-west-1 --create-bucket-configuration LocationConstraint=eu-west-1
```

## Movimiento 2 — Dockerfile + buildspec.yml → S3

```dockerfile
FROM alpine:latest
RUN apk update && apk add --no-cache apache2
RUN echo "cmtr-iacp1ebx" > /var/www/localhost/htdocs/index.html
EXPOSE 80
CMD ["httpd", "-D", "FOREGROUND"]
```

```yaml
version: 0.2
phases:
  pre_build:
    commands:
      - aws ecr get-login-password --region eu-west-1 | docker login --username AWS --password-stdin 911167900226.dkr.ecr.eu-west-1.amazonaws.com
  build:
    commands:
      - docker build -t cmtr-iacp1ebx:alpine-httpd .
      - docker tag cmtr-iacp1ebx:alpine-httpd 911167900226.dkr.ecr.eu-west-1.amazonaws.com/cmtr-iacp1ebx:alpine-httpd
  post_build:
    commands:
      - docker push 911167900226.dkr.ecr.eu-west-1.amazonaws.com/cmtr-iacp1ebx:alpine-httpd
```

```bash
powershell -Command "Compress-Archive -Path Dockerfile,buildspec.yml -DestinationPath build-source.zip -Force"
aws s3 cp build-source.zip s3://cmtr-iacp1ebx-bucket-13120/build-source.zip
```

## Movimiento 3 — Proyecto CodeBuild y ejecución

```bash
aws codebuild create-project \
  --name cmtr-iacp1ebx-project \
  --source type=S3,location=cmtr-iacp1ebx-bucket-13120/build-source.zip \
  --artifacts type=NO_ARTIFACTS \
  --environment type=LINUX_CONTAINER,image=aws/codebuild/standard:7.0,computeType=BUILD_GENERAL1_SMALL,privilegedMode=true \
  --service-role arn:aws:iam::911167900226:role/cmtr-iacp1ebx-cb \
  --region eu-west-1

aws codebuild start-build --project-name cmtr-iacp1ebx-project --region eu-west-1
```
`privilegedMode=true` es obligatorio para que el build pueda correr `docker build` dentro del contenedor de build de CodeBuild (Docker-in-Docker). Build exitoso (`SUCCEEDED`), imagen confirmada en ECR con tag `alpine-httpd`.

## Movimiento 4 — Rol IAM + instancia EC2

```bash
aws iam create-role --role-name cmtr-iacp1ebx-ec2-ssm --assume-role-policy-document file://ec2-trust-policy.json  # trust: ec2.amazonaws.com
aws iam attach-role-policy --role-name cmtr-iacp1ebx-ec2-ssm --policy-arn arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore
aws iam create-instance-profile --instance-profile-name cmtr-iacp1ebx-ec2-ssm-profile
aws iam add-role-to-instance-profile --instance-profile-name cmtr-iacp1ebx-ec2-ssm-profile --role-name cmtr-iacp1ebx-ec2-ssm

aws ec2 run-instances \
  --image-id ami-00b98fcf187a433fa \
  --instance-type t3.micro \
  --subnet-id subnet-02239357af3eae82e \
  --security-group-ids $SG_ID \
  --associate-public-ip-address \
  --iam-instance-profile Name=cmtr-iacp1ebx-ec2-ssm-profile \
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=cmtr-iacp1ebx-instance},{Key=app,Value=alpine-httpd}]'
```

## Movimiento 5 — Instalar el agente de CodeDeploy (paso no listado explícitamente en el enunciado, pero necesario)

```bash
aws ssm send-command --instance-ids $INSTANCE_ID --document-name "AWS-RunShellScript" --parameters 'commands=[
  "sudo dnf install -y ruby wget",
  "cd /home/ec2-user",
  "wget https://aws-codedeploy-eu-west-1.s3.eu-west-1.amazonaws.com/latest/install",
  "chmod +x ./install",
  "sudo ./install auto"
]' --region eu-west-1
```

## Movimiento 6 — Rol de CodeDeploy, aplicación y deployment group

```bash
aws iam create-role --role-name cmtr-iacp1ebx-cd --assume-role-policy-document file://cd-trust-policy.json  # trust: codedeploy.amazonaws.com
aws iam attach-role-policy --role-name cmtr-iacp1ebx-cd --policy-arn arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole

aws deploy create-application --application-name cd-alpine-httpd --compute-platform Server --region eu-west-1

aws deploy create-deployment-group \
  --application-name cd-alpine-httpd \
  --deployment-group-name cd-alpine-httpd \
  --service-role-arn arn:aws:iam::911167900226:role/cmtr-iacp1ebx-cd \
  --ec2-tag-filters Key=app,Value=alpine-httpd,Type=KEY_AND_VALUE \
  --deployment-config-name CodeDeployDefault.AllAtOnce \
  --region eu-west-1
```
Sin especificar `--deployment-type`, por defecto es `IN_PLACE` (cumple el requisito).

## Movimiento 7 — Scripts de despliegue + appspec.yml → S3

```bash
#!/bin/bash
# install_dependencies.sh
sudo dnf update -y
sudo dnf install -y docker
sudo systemctl start docker
sudo systemctl enable docker
aws ecr get-login-password --region eu-west-1 | sudo docker login --username AWS --password-stdin 911167900226.dkr.ecr.eu-west-1.amazonaws.com
sudo docker pull 911167900226.dkr.ecr.eu-west-1.amazonaws.com/cmtr-iacp1ebx:alpine-httpd
```
```bash
#!/bin/bash
# run_app.sh
sudo docker rm -f alpine-httpd || true
sudo docker run -d -p 80:80 --name alpine-httpd 911167900226.dkr.ecr.eu-west-1.amazonaws.com/cmtr-iacp1ebx:alpine-httpd
```
```yaml
# appspec.yml
version: 0.0
os: linux
files:
  - source: /
    destination: /home/ec2-user/app
hooks:
  AfterInstall:
    - location: install_dependencies.sh
      timeout: 300
      runas: root
  ApplicationStart:
    - location: run_app.sh
      timeout: 300
      runas: root
```

Nota: los `.sh` se escribieron con `printf` (no heredoc/editor de Windows) para garantizar saltos de línea LF puros, tal como exige el enunciado.

```bash
powershell -Command "Compress-Archive -Path appspec.yml,install_dependencies.sh,run_app.sh -DestinationPath deploy-source.zip -Force"
aws s3 cp deploy-source.zip s3://cmtr-iacp1ebx-bucket-13120/deploy-source.zip
```

## Incidentes durante el deployment

### Intento 1 — falla en `DownloadBundle`
```
User: .../cmtr-iacp1ebx-ec2-ssm/... is not authorized to perform: s3:GetObject on resource: "...deploy-source.zip"
```
El rol de la instancia solo tenía `AmazonSSMManagedInstanceCore` — el agente de CodeDeploy descarga el bundle usando las credenciales de la propia instancia, no un rol de CodeDeploy. **Fix**: `aws iam attach-role-policy ... AmazonS3ReadOnlyAccess`.

### Intento 2 — mismo error de S3, pese a la policy ya adjunta
Las credenciales ya cacheadas por el agente (obtenidas antes del cambio de IAM) no se habían renovado. **Fix**: `systemctl restart codedeploy-agent` para forzar la obtención de credenciales frescas.

### Intento 3 — avanza hasta `AfterInstall`, falla `install_dependencies.sh`
```
AccessDeniedException ... ecr:GetAuthorizationToken ... "Cannot perform an interactive login from a non TTY device"
"no basic auth credentials"
```
Diagnosticado leyendo `/opt/codedeploy-agent/deployment-root/.../scripts.log` directamente en la instancia (vía SSM), ya que el log del propio `get-deployment-instance` contenía un carácter Unicode que rompía la consola local (`tr -cd '\11\12\15\40-\176'` para sanear el output antes de imprimirlo). **Fix**: `AmazonEC2ContainerRegistryReadOnly` adjunta al rol de instancia + reinicio del agente.

### Intento 4 — exitoso
```bash
aws deploy create-deployment --application-name cd-alpine-httpd --deployment-group-name cd-alpine-httpd \
  --s3-location bucket=cmtr-iacp1ebx-bucket-13120,key=deploy-source.zip,bundleType=zip --region eu-west-1
```
`deploymentInfo.status: Succeeded`.

## Verificación

```bash
aws ssm send-command --instance-ids $INSTANCE_ID --document-name "AWS-RunShellScript" --parameters 'commands=["curl -s localhost:80"]' --region eu-west-1
```
Devolvió `cmtr-iacp1ebx` — el contenedor Docker corriendo httpd responde correctamente.
