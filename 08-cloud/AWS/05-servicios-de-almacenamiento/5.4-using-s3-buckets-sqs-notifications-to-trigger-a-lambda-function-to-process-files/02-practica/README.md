# Práctica — Using S3 Bucket's SQS Notifications to Trigger a Lambda Function

## Enunciado de la tarea

> When a file is added to `input/` in an S3 bucket, a notification is sent to an SQS queue, triggering a Lambda function that processes the file and stores the result in `output/`.

**Región:** `eu-west-1` — Cuenta `976193228318`

**Recursos de la tarea** (permisos ya configurados de antemano):
- Bucket `cmtr-iacp1ebx-s3-snlt-bucket-188162`
- Cola SQS `cmtr-iacp1ebx-s3-snlt-queue`
- Lambda `cmtr-iacp1ebx-s3-snlt-lambda`

**Objetivos (3 movimientos):**
1. Notificación de eventos del bucket (prefijo `input/`, `s3:ObjectCreated:*`) hacia la cola SQS.
2. Trigger de Lambda sobre la cola SQS (esperar a que quede creado).
3. Subir un `.txt` a `input/` para probar el flujo completo.

**Entorno real usado:** trabajado por **CLI** en CloudShell.

---

## Movimiento 1 — Notificación S3 → SQS

```bash
SQS_ARN=$(aws sqs get-queue-attributes \
  --queue-url $(aws sqs get-queue-url --queue-name cmtr-iacp1ebx-s3-snlt-queue --region eu-west-1 --query 'QueueUrl' --output text) \
  --attribute-names QueueArn --region eu-west-1 --query 'Attributes.QueueArn' --output text)

cat > notification-config.json << EOF
{
  "QueueConfigurations": [
    {
      "QueueArn": "${SQS_ARN}",
      "Events": ["s3:ObjectCreated:*"],
      "Filter": {
        "Key": {
          "FilterRules": [
            {"Name": "prefix", "Value": "input/"}
          ]
        }
      }
    }
  ]
}
EOF

aws s3api put-bucket-notification-configuration \
  --bucket cmtr-iacp1ebx-s3-snlt-bucket-188162 \
  --notification-configuration file://notification-config.json \
  --region eu-west-1
```

## Movimiento 2 — Trigger de Lambda sobre SQS

```bash
aws lambda create-event-source-mapping \
  --function-name cmtr-iacp1ebx-s3-snlt-lambda \
  --event-source-arn $SQS_ARN \
  --batch-size 10 \
  --region eu-west-1
```
Se obtiene un `UUID` de mapping con `State: Creating`. Hay que esperar a que pase a `Enabled` antes de continuar:
```bash
sleep 20
aws lambda get-event-source-mapping --uuid <UUID> --region eu-west-1 --query 'State' --output text
# Enabled
```

## Movimiento 3 — Subir un archivo de prueba

```bash
echo "contenido de prueba" > sample.txt
aws s3 cp sample.txt s3://cmtr-iacp1ebx-s3-snlt-bucket-188162/input/sample.txt

sleep 30
aws s3 ls s3://cmtr-iacp1ebx-s3-snlt-bucket-188162/output/ --recursive
```
```
2026-09-03 11:52:42         20 output/lambdahandled_input/sample.txt
```

El archivo procesado aparece en una subcarpeta (`output/lambdahandled_input/`), creada automáticamente por la Lambda — tal como anticipaba el enunciado ("The `output/` folder will be created automatically").

## Verificación

```bash
aws s3api get-bucket-notification-configuration --bucket cmtr-iacp1ebx-s3-snlt-bucket-188162 --region eu-west-1
aws lambda list-event-source-mappings --function-name cmtr-iacp1ebx-s3-snlt-lambda --region eu-west-1
```

Lab directo, sin incidentes de configuración — solo el tiempo de espera normal para que el event source mapping quede `Enabled`.
