# Práctica — Implement Simple Lambda Function with SNS Integration

## Enunciado de la tarea

> Create a Lambda function that receives `{"ip_address": "..."}`, queries the IPinfo public API for the city, and publishes `{"ip_address": ..., "city": ...}` to an SNS topic — with the topic subscribed by both an email address and an SQS queue.

**Región:** `eu-west-1` — Cuenta `913524900817`

**Entorno real usado:** CLI local (Git Bash).

---

## Movimiento 1 — SNS topic + suscripciones

```bash
aws sns create-topic --name cmtr-iacp1ebx-sns --region eu-west-1

aws sns subscribe \
  --topic-arn arn:aws:sns:eu-west-1:913524900817:cmtr-iacp1ebx-sns \
  --protocol email \
  --notification-endpoint cesar_buitrago@epam.com \
  --region eu-west-1
# Requiere clic en el link de confirmación recibido por correo

aws sqs create-queue --queue-name cmtr-iacp1ebx-sqs --region eu-west-1
```

## Movimiento 2 — Queue policy + suscripción SQS

```bash
cat > sqs-attrs.json << 'EOF'
{
  "Policy": "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Allow\",\"Principal\":{\"Service\":\"sns.amazonaws.com\"},\"Action\":\"sqs:SendMessage\",\"Resource\":\"arn:aws:sqs:eu-west-1:913524900817:cmtr-iacp1ebx-sqs\",\"Condition\":{\"ArnEquals\":{\"aws:SourceArn\":\"arn:aws:sns:eu-west-1:913524900817:cmtr-iacp1ebx-sns\"}}}]}"
}
EOF

aws sqs set-queue-attributes \
  --queue-url https://sqs.eu-west-1.amazonaws.com/913524900817/cmtr-iacp1ebx-sqs \
  --attributes file://sqs-attrs.json --region eu-west-1

aws sns subscribe \
  --topic-arn arn:aws:sns:eu-west-1:913524900817:cmtr-iacp1ebx-sns \
  --protocol sqs \
  --notification-endpoint arn:aws:sqs:eu-west-1:913524900817:cmtr-iacp1ebx-sqs \
  --region eu-west-1
```
Nota: intentar pasar el policy como un objeto JSON anidado directamente en `--attributes` falla (`ParamValidation: Invalid type for parameter Attributes.Statement... valid types: <class 'str'>`) — el atributo `Policy` de SQS espera el JSON como **string escapado**, no como objeto.

## Movimiento 3 — Rol IAM para Lambda

```bash
cat > lambda-trust-policy.json << 'EOF'
{"Version":"2012-10-17","Statement":[{"Effect":"Allow","Principal":{"Service":"lambda.amazonaws.com"},"Action":"sts:AssumeRole"}]}
EOF

aws iam create-role --role-name cmtr-iacp1ebx-lambda_sns_role --assume-role-policy-document file://lambda-trust-policy.json
aws iam attach-role-policy --role-name cmtr-iacp1ebx-lambda_sns_role --policy-arn arn:aws:iam::aws:policy/AmazonSNSFullAccess
aws iam attach-role-policy --role-name cmtr-iacp1ebx-lambda_sns_role --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole
```

## Movimiento 4 — Código y despliegue de la función

```python
# lambda_function.py
import json
import os
import urllib.request
import boto3

sns = boto3.client('sns')
TOPIC_ARN = os.environ['SNS_TOPIC_ARN']

def lambda_handler(event, context):
    ip_address = event['ip_address']
    url = f"https://ipinfo.io/{ip_address}/json"

    with urllib.request.urlopen(url) as response:
        data = json.loads(response.read().decode())

    city = data.get('city')
    result = {"ip_address": ip_address, "city": city}

    sns.publish(TopicArn=TOPIC_ARN, Message=json.dumps(result), Subject="IP City Lookup Result")
    return result
```

### Incidente: `zip` no disponible en Git Bash

**Fix**: usar PowerShell desde la misma terminal Git Bash para comprimir:
```bash
powershell -Command "Compress-Archive -Path lambda_function.py -DestinationPath lambda_function.zip -Force"
```

```bash
aws lambda create-function \
  --function-name cmtr-iacp1ebx-lambda \
  --runtime python3.12 \
  --role arn:aws:iam::913524900817:role/cmtr-iacp1ebx-lambda_sns_role \
  --handler lambda_function.lambda_handler \
  --zip-file fileb://lambda_function.zip \
  --timeout 15 \
  --environment "Variables={SNS_TOPIC_ARN=arn:aws:sns:eu-west-1:913524900817:cmtr-iacp1ebx-sns}" \
  --region eu-west-1
```

## Verificación

```bash
aws lambda invoke --function-name cmtr-iacp1ebx-lambda \
  --payload '{"ip_address": "8.8.8.8"}' --cli-binary-format raw-in-base64-out \
  --region eu-west-1 response.json
cat response.json
# {"ip_address": "8.8.8.8", "city": "Mountain View"}

aws sqs receive-message --queue-url https://sqs.eu-west-1.amazonaws.com/913524900817/cmtr-iacp1ebx-sqs --region eu-west-1
```
El mensaje llegó correctamente a SQS (envuelto en el sobre de notificación de SNS) y por email.
