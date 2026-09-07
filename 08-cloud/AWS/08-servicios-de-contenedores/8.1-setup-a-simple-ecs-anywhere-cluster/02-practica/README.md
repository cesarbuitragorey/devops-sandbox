# Práctica — Setup a Simple ECS Anywhere Cluster

## Enunciado de la tarea

> Create an ECS Anywhere cluster and register an external Linux VM to it as a container instance, using an SSM activation with registration limit 1.

**Región:** `eu-west-1` — Cuenta `535002879489`

**Objetivos:**
1. Cluster ECS `cmtr-iacp1ebx-cluster`
2. Rol IAM `ecsExternalInstanceRole` (crearlo si no existe)
3. Activación SSM (límite de registro = 1)
4. Registrar una VM Linux soportada como external instance

**VM usada:** WSL2 con Ubuntu 22.04 (en vez de VirtualBox — más rápido de levantar, cumple los mismos requisitos, ver teoría).

**Entorno real usado:** AWS CloudShell para los comandos de AWS; WSL2/Ubuntu (en la máquina local) como la "VM externa" a registrar.

---

## Movimiento 1 — Levantar la VM Linux (WSL2 + Ubuntu 22.04)

```powershell
wsl --install -d Ubuntu-22.04
```

Tras crear el usuario Linux, se habilitó `systemd` (requerido por el instalador de ECS Anywhere):
```bash
echo -e "[boot]\nsystemd=true" | sudo tee /etc/wsl.conf
```
```powershell
wsl --shutdown
wsl -d Ubuntu-22.04
```
Verificado con `ps -p 1 -o comm=` → `systemd` (en esta versión de WSL2 ya venía activo incluso antes del reinicio).

## Movimiento 2 — Cluster ECS y rol IAM (en CloudShell)

```bash
aws ecs create-cluster --cluster-name cmtr-iacp1ebx-cluster --region eu-west-1
```

```bash
cat > ecs-anywhere-trust-policy.json << 'EOF'
{
  "Version": "2012-10-17",
  "Statement": [
    {"Effect": "Allow", "Principal": {"Service": "ssm.amazonaws.com"}, "Action": "sts:AssumeRole"}
  ]
}
EOF

aws iam create-role --role-name ecsExternalInstanceRole --assume-role-policy-document file://ecs-anywhere-trust-policy.json
aws iam attach-role-policy --role-name ecsExternalInstanceRole --policy-arn arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role
aws iam attach-role-policy --role-name ecsExternalInstanceRole --policy-arn arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore
```

## Movimiento 3 — Generar la activación SSM

```bash
aws ssm create-activation \
  --iam-role ecsExternalInstanceRole \
  --registration-limit 1 \
  --region eu-west-1
```
Devuelve `ActivationId` y `ActivationCode` (de un solo uso).

## Movimiento 4 — Registrar la VM externa

Dentro de la VM Ubuntu (WSL2):
```bash
curl --proto "https" -o "/tmp/ecs-anywhere-install.sh" "https://amazon-ecs-agent.s3.amazonaws.com/ecs-anywhere-install-latest.sh"

sudo bash /tmp/ecs-anywhere-install.sh \
    --region eu-west-1 \
    --cluster cmtr-iacp1ebx-cluster \
    --activation-id <ActivationId> \
    --activation-code <ActivationCode>
```
Instala y verifica (GPG) el agente SSM, instala Docker desde el repo oficial, instala y arranca el agente ECS. Termina con:
```
Ping ECS Agent registered successfully! Container instance arn: "arn:aws:ecs:eu-west-1:535002879489:container-instance/cmtr-iacp1ebx-cluster/..."
```

### Incidente: nombre de archivo incorrecto del script

Primer intento con `ecs-anywhere-install.sh` (sin `-latest`) devolvió un XML `AccessDenied` de S3 en vez del script. **Fix**: el nombre correcto según la documentación actual de AWS es `ecs-anywhere-install-latest.sh`.

## Verificación

```bash
aws ecs describe-container-instances \
  --cluster cmtr-iacp1ebx-cluster \
  --container-instances <container-instance-arn> \
  --query 'containerInstances[0].{Status:status,AgentConnected:agentConnected,Attributes:attributes}'
```
Confirmó `Status: ACTIVE`, `AgentConnected: true`, y entre los atributos: `ecs.capability.external`, `ecs.os-type: linux`, `ecs.os-type-detailed: ubuntu_22.04`.
