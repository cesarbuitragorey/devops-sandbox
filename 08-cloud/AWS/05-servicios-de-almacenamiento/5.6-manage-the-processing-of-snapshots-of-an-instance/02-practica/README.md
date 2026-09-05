# Práctica — Manage the Processing of Snapshots of an Instance

> **Estado: ⏳ Pendiente.** La secuencia de comandos de abajo produce una configuración verificada como correcta (ver `03-resultados`), pero el check automatizado de la plataforma no la acepta todavía. Documento igual el procedimiento completo porque el trabajo de descubrir la sintaxis correcta de la API fue el grueso del esfuerzo de este lab.

## Enunciado de la tarea

> Create snapshots of an instance running MySQL using DLM, stopping MySQL before the snapshot and resuming it afterward via pre/post scripts.

**Región:** `eu-west-1`

**Recursos de la tarea:**
- EC2 con MySQL corriendo (ID distinto en cada intento — el sandbox se reinició una vez)
- IAM Role `cmtr-iacp1ebx-ec2-s-DLMFullAccess`

**Objetivos (2 movimientos):**
1. SSM Document (tipo Command) que detiene/arranca mysql, con un parámetro de valores permitidos `"pre-script"`/`"post-script"`.
2. Política de DLM apuntando a la instancia por su tag `Name=cmtr-iacp1ebx-ec2-s-instance`, intervalo 1h, retener 3 snapshots, con el SSM document asignado, y tag `Name=cmtr-iacp1ebx-policy` en la propia política.

**Entorno real usado:** trabajado por **CLI** en CloudShell, en dos sandboxes distintos (el segundo tras un "Restart task" en la plataforma).

---

## Movimiento 1 — SSM Document

```bash
aws configure set region eu-west-1   # fijar región de forma persistente, no solo por variable de entorno

cat > mysql-prepost-doc.json << 'EOF'
{
  "schemaVersion": "2.2",
  "description": "Stops or starts MySQL before/after a DLM snapshot, based on current status",
  "parameters": {
    "command": {
      "type": "String",
      "description": "pre-script or post-script",
      "default": "pre-script",
      "allowedValues": ["pre-script", "post-script"]
    }
  },
  "mainSteps": [
    {
      "action": "aws:runShellScript",
      "name": "manageMysql",
      "inputs": {
        "runCommand": [
          "if systemctl is-active --quiet mysqld; then sudo systemctl stop mysqld; else sudo systemctl start mysqld; fi"
        ]
      }
    }
  ]
}
EOF

aws ssm create-document \
  --name cmtr-iacp1ebx-mysql-prepost-doc \
  --document-type Command \
  --document-format JSON \
  --content file://mysql-prepost-doc.json \
  --region eu-west-1
```

### Incidentes durante el diseño del documento

**Intento 1** — parámetro llamado `action`: la política de DLM (Movimiento 2) fallaba con:
```
InvalidRequestException: ... The specified SSM document must provide allowed values in {parameters.command.allowedValues}
```
El propio mensaje de error reveló el nombre de parámetro exacto y obligatorio: **`command`**. Se corrigió con `aws ssm update-document` (nueva versión) + `update-document-default-version`.

## Movimiento 2 — Política de DLM

```bash
ROLE_ARN=$(aws iam get-role --role-name cmtr-iacp1ebx-ec2-s-DLMFullAccess --query 'Role.Arn' --output text)

cat > dlm-policy-details.json << 'EOF'
{
  "PolicyType": "EBS_SNAPSHOT_MANAGEMENT",
  "ResourceTypes": ["INSTANCE"],
  "TargetTags": [
    {"Key": "Name", "Value": "cmtr-iacp1ebx-ec2-s-instance"}
  ],
  "Schedules": [
    {
      "Name": "cmtr-iacp1ebx-schedule",
      "CopyTags": false,
      "CreateRule": {
        "Interval": 1,
        "IntervalUnit": "HOURS",
        "Scripts": [
          {
            "Stages": ["PRE", "POST"],
            "ExecutionHandlerService": "AWS_SYSTEMS_MANAGER",
            "ExecutionHandler": "cmtr-iacp1ebx-mysql-prepost-doc",
            "ExecuteOperationOnScriptFailure": true,
            "ExecutionTimeout": 10,
            "MaximumRetryCount": 3
          }
        ]
      },
      "RetainRule": {"Count": 3}
    }
  ]
}
EOF

aws dlm create-lifecycle-policy \
  --description "cmtr-iacp1ebx-policy" \
  --state ENABLED \
  --execution-role-arn $ROLE_ARN \
  --policy-details file://dlm-policy-details.json \
  --tags Key=Name,Value=cmtr-iacp1ebx-policy \
  --region eu-west-1
```

### Incidentes durante el diseño de la política

**Intento 1** — `Scripts` como hermano de `CreateRule` dentro de `Schedules[]`:
```
ParamValidation: Unknown parameter in PolicyDetails.Schedules[0]: "Scripts",
must be one of: Name, CopyTags, TagsToAdd, VariableTags, CreateRule, RetainRule, ...
```
**Fix**: correr `aws dlm create-lifecycle-policy --generate-cli-skeleton` para ver el schema real completo — reveló que `Scripts` vive dentro de `CreateRule`.

**Intento 2** — dos entradas separadas en `Scripts` (una `Stages: ["PRE"]`, otra `Stages: ["POST"]`):
```
LimitExceededException: You've reached the limit on the number of scripts you can include in a schedule.
You can specify up to {1} script(s) per schedule for up to {1} schedule(s) per policy.
```
**Fix**: combinar ambos estados en una sola entrada: `"Stages": ["PRE", "POST"]`.

**Intento 3** — parámetro del documento SSM llamado `action` en vez de `command` → ver incidente del Movimiento 1.

## Verificación manual (por CLI) — exitosa

```bash
aws dlm get-lifecycle-policies --resource-types INSTANCE --region eu-west-1
aws dlm get-lifecycle-policy --policy-id <policy-id> --region eu-west-1
```
Confirma en ambos intentos (dos sandboxes distintos): `State: ENABLED`, `TargetTags` con el valor exacto de la instancia (verificado además byte a byte con `xxd`), `RetainRule.Count: 3`, `CreateRule.Interval: 1/HOURS`, y el script con `Stages: ["PRE","POST"]` apuntando al documento correcto.

## Lo que sigue sin resolverse

El check #1 de la plataforma ("Checks if the DLM policy... assigned to existing instance") devuelve `std_out` vacío (exit code 0, sin error) en ambos sandboxes, pese a la configuración verificada como correcta. Hipótesis pendientes de probar:
- El checker podría ejecutarse **desde dentro de la instancia EC2** (vía SSM) usando una configuración de región del CLI distinta a `eu-west-1` — no confirmado si `~/.aws/config` dentro de la instancia tiene la región fijada (en CloudShell sí hacía falta fijarla explícitamente, según se descubrió en este mismo lab).
- El check podría depender de que exista al menos **un snapshot ya creado** por la política (evidencia de ejecución real), no solo de la configuración — no se confirmó, ya que en ninguno de los dos intentos se esperó lo suficiente para ver el primer snapshot programado.
