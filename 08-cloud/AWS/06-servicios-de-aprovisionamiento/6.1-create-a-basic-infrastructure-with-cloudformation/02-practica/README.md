# Práctica — Create a Basic Infrastructure with CloudFormation

## Enunciado de la tarea

> Build a basic VPC infrastructure entirely via a CloudFormation template: VPC with 2 public subnets (one per AZ), Internet Gateway, route tables, a security group (SSH + HTTP), 2 EC2 instances each running httpd with a region-specific message, and an IAM role for SSM — deployed via a dedicated CloudFormation service role.

**Región:** `eu-west-1` — Cuenta `913524907044`

**Recursos esperados de la tarea:**
- VPC `cmtr-iacp1ebx-vpc` (`10.0.0.0/16`), subnets `cmtr-iacp1ebx-subnet1` (`eu-west-1a`) y `cmtr-iacp1ebx-subnet2` (`eu-west-1b`)
- Internet Gateway + rutas públicas hacia `0.0.0.0/0`
- Security Group `cmtr-iacp1ebx-sg` (22/tcp, 80/tcp)
- Rol IAM `cmtr-iacp1ebx-role` con `AmazonSSMManagedInstanceCore` + instance profile
- Instancias `cmtr-iacp1ebx-instance1` (subnet1, "Hello from Region eu-west-1a") y `cmtr-iacp1ebx-instance2` (subnet2, "Hello from Region eu-west-1b")
- Todo etiquetado con `Maintainer: cmtr-iacp1ebx-maintainer` (parámetro de la plantilla)

**Entorno real usado:** CLI local (PowerShell 5.1 en Windows), no CloudShell — ver incidente más abajo.

---

## Incidente: CloudShell bloqueado por Service Control Policy

Al intentar abrir CloudShell:
```
Unable to create the environment for this account:
User: ... is not authorized to perform: cloudshell:CreateEnvironment ...
with an explicit deny in a service control policy
```
**Fix**: configurar el AWS CLI local con las credenciales temporales STS provistas por el sandbox:
```powershell
aws configure set aws_access_key_id ASIA...
aws configure set aws_secret_access_key ...
aws configure set aws_session_token ...
aws configure set region eu-west-1
```

## Movimiento 1 — Rol de servicio para CloudFormation

```powershell
@'
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "cloudformation.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
'@ | Out-File -Encoding ascii trust-policy.json

aws iam create-role `
  --role-name cmtr-iacp1ebx-cfn-role `
  --assume-role-policy-document file://trust-policy.json

aws iam attach-role-policy `
  --role-name cmtr-iacp1ebx-cfn-role `
  --policy-arn arn:aws:iam::aws:policy/AdministratorAccess
```

### Incidentes al crear el rol

**Intento 1** — pasar el JSON de la política de confianza inline como argumento:
```
An error occurred (MalformedPolicyDocument) when calling the CreateRole operation:
This policy contains invalid Json
```
El JSON se veía correcto al hacer echo, pero PowerShell mangla comillas/espacios al pasar JSON inline como argumento. **Fix**: escribirlo a un archivo y referenciarlo con `file://trust-policy.json`.

**Intento 2** — con el archivo, mismo error `MalformedPolicyDocument`. Causa real: `Out-File -Encoding utf8` en PowerShell 5.1 antepone un BOM (Byte Order Mark) al archivo, y el parser JSON del AWS CLI (Python) no tolera el BOM inicial. **Fix**: usar `-Encoding ascii` en vez de `utf8` (seguro porque el contenido es ASCII puro, sin caracteres especiales) — funcionó de inmediato tras el cambio.

## Movimiento 2 — Plantilla CloudFormation

Ver [`basic-infra.yml`](basic-infra.yml), copiado en esta misma carpeta. Recursos principales: `VPC`, `Subnet1`/`Subnet2`, `InternetGateway` + `AttachGateway`, `PublicRouteTable1`/`2` + rutas + asociaciones, `SecurityGroup`, `InstanceRole` + `InstanceProfile`, `Instance1`/`Instance2` con `UserData` que instala y arranca `httpd` con el mensaje de región correspondiente.

Parámetros clave:
- `Maintainer` (default `cmtr-iacp1ebx-maintainer`) — propagado como tag en todos los recursos vía `!Ref Maintainer`
- `LatestAmiId` — tipo `AWS::SSM::Parameter::Value<AWS::EC2::Image::Id>`, resuelve el AMI de Amazon Linux 2023 más reciente automáticamente

## Movimiento 3 — Despliegue del stack

```powershell
ROLE_ARN = aws iam get-role --role-name cmtr-iacp1ebx-cfn-role --query 'Role.Arn' --output text

aws cloudformation create-stack `
  --stack-name cmtr-iacp1ebx-basic-infra `
  --template-body file://basic-infra.yml `
  --role-arn $ROLE_ARN `
  --capabilities CAPABILITY_NAMED_IAM

aws cloudformation wait stack-create-complete --stack-name cmtr-iacp1ebx-basic-infra

aws cloudformation describe-stacks `
  --stack-name cmtr-iacp1ebx-basic-infra `
  --query 'Stacks[0].StackStatus'
```
Resultado: `"CREATE_COMPLETE"` (`StackId: arn:aws:cloudformation:eu-west-1:913524907044:stack/cmtr-iacp1ebx-basic-infra/ef6d9e30-a937-11f1-9cbd-06a7081b656d`).

## Verificación

```powershell
aws ssm describe-instance-information --query 'InstanceInformationList[].[InstanceId,PingStatus]' --output table
```
Ambas instancias `Online` en Systems Manager. El "Check" de la plataforma verificó directamente (sin necesidad de `ssm start-session` manual, bloqueado localmente por falta del plugin de Session Manager) que:
- `curl localhost` en cada instancia devuelve el mensaje esperado (`Hello from Region eu-west-1a` / `...1b`)
- Ambas instancias responden `200` desde Internet (subnets públicas + security group correctos)
