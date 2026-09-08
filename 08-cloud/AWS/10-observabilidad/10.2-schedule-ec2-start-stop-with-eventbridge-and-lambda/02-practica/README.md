# Práctica — Schedule EC2 Start/Stop with EventBridge and Lambda

## Enunciado de la tarea

> Configure the schedule and target input for two pre-existing EventBridge rules (start at 8:00 UTC, stop at 20:00 UTC) so they invoke a pre-existing Lambda function to start/stop the "unmanaged" EC2 instance.

**Región:** `eu-west-1` — Cuenta `565393074387`

**Recursos pre-creados:** rol/policy IAM, Lambda `cmtr-iacp1ebx-eventbridge-lesm-lambda` (código ya desplegado), instancias `i-02dfea22d09a20b52` (managed=yes) e `i-00fd0ec4dfc307c0a` (managed=no, el target real), reglas `...event_rule-start`/`...event_rule-stop` (con cron placeholder inútil y targets sin `Input`).

**Entorno real usado:** CLI local (Git Bash).

---

## Movimiento 1 — Leer el código de la Lambda para determinar el formato del payload

```bash
aws lambda get-function --function-name cmtr-iacp1ebx-eventbridge-lesm-lambda
curl -s "<url-firmada-de-S3-del-get-function>" -o lambda-code.zip
powershell -Command "Expand-Archive -Path lambda-code.zip -DestinationPath lambda-code -Force"
cat lambda-code/manage_ec2_instance.py
```
Hallazgos clave del código:
- Espera `event['action']` (`start`/`stop`).
- Espera opcionalmente `event['tags']` (string `tag:clave=valor`, separado por comas si hay varios); si no se provee, usa la variable de entorno `DEFAULT_TAGS` = `tag:managed=yes`.
- Como el objetivo real es la instancia **unmanaged** (`managed=no`), había que pasar `tags` explícitamente en cada regla — de lo contrario la función operaría sobre la instancia equivocada (la managed, por el default).

## Movimiento 2 — Diagnóstico de las reglas existentes

```bash
aws events describe-rule --name cmtr-iacp1ebx-eventbridge-lesm-event_rule-start
aws events list-targets-by-rule --rule cmtr-iacp1ebx-eventbridge-lesm-event_rule-start
```
Ambas reglas ya tenían el target correcto (ARN de la Lambda) pero:
- `ScheduleExpression: cron(* * ? * * 1970)` — cron placeholder con año 1970, nunca dispara.
- Sin `Input` configurado en el target.

## Movimiento 3 — Corregir schedule y payload

```bash
aws events put-rule --name cmtr-iacp1ebx-eventbridge-lesm-event_rule-start --schedule-expression "cron(0 8 * * ? *)" --state ENABLED
aws events put-rule --name cmtr-iacp1ebx-eventbridge-lesm-event_rule-stop --schedule-expression "cron(0 20 * * ? *)" --state ENABLED

aws events put-targets --rule cmtr-iacp1ebx-eventbridge-lesm-event_rule-start \
  --targets '[{"Id":"terraform-20260908125610876400000005","Arn":"arn:aws:lambda:eu-west-1:565393074387:function:cmtr-iacp1ebx-eventbridge-lesm-lambda","Input":"{\"action\":\"start\",\"tags\":\"tag:managed=no\"}"}]'

aws events put-targets --rule cmtr-iacp1ebx-eventbridge-lesm-event_rule-stop \
  --targets '[{"Id":"terraform-20260908125610873700000004","Arn":"arn:aws:lambda:eu-west-1:565393074387:function:cmtr-iacp1ebx-eventbridge-lesm-lambda","Input":"{\"action\":\"stop\",\"tags\":\"tag:managed=no\"}"}]'
```
Nota: se reutilizó el `Id` de target ya existente (visible en `list-targets-by-rule`) — `put-targets` actualiza el target si el `Id` coincide, en vez de crear uno duplicado.

## Verificación manual (siguiendo la guía del enunciado)

```bash
aws lambda invoke --function-name cmtr-iacp1ebx-eventbridge-lesm-lambda --payload '{"action":"stop","tags":"tag:managed=no"}' --cli-binary-format raw-in-base64-out stop-response.json
aws ec2 describe-instances --instance-ids i-00fd0ec4dfc307c0a --query 'Reservations[0].Instances[0].State.Name' --output text
# stopping

aws lambda invoke --function-name cmtr-iacp1ebx-eventbridge-lesm-lambda --payload '{"action":"start","tags":"tag:managed=no"}' --cli-binary-format raw-in-base64-out start-response.json
```
Confirmó que la Lambda actúa correctamente sobre la instancia "unmanaged" cuando se le pasa el `tags` correcto — el mismo payload que ahora llevan configurado las 2 reglas de EventBridge.
