# Práctica — Using AWS Lambda Function with API Gateway

## Enunciado de la tarea

> Grant the correct permissions to a Lambda function so that it can access the necessary resources and other resources can access it as well.

**Región:** `eu-west-1`

**Recursos de la tarea** (ya provisionados por el sandbox):
- Lambda function: `cmtr-iacp1ebx-iam-lp-lambda` (retorna la lista de funciones Lambda de la cuenta)
- Execution role: `cmtr-iacp1ebx-iam-lp-iam_role`
- API Gateway (HTTP API): `cmtr-iacp1ebx-iam-lp-apigwv2_api`

**Objetivos (2 movimientos):**
1. Dar al rol de ejecución los permisos necesarios (según el código de la función) usando una política administrada por AWS de acciones de la API de Lambda, con mínimo privilegio.
2. Dar permiso a la HTTP API para invocar la función (`add-permission`).

**Entorno real usado:** sandbox AWS, cuenta `291160880726`. Trabajé por **CLI**.

---

## Movimiento 1 — Permisos del rol de ejecución

La función retorna la lista de funciones Lambda de la cuenta → necesita `lambda:ListFunctions`. La política administrada por AWS que cubre acciones de solo lectura de la API de Lambda (mínimo privilegio frente a `AWSLambda_FullAccess`) es `AWSLambda_ReadOnlyAccess`:

```bash
aws iam attach-role-policy \
  --role-name cmtr-iacp1ebx-iam-lp-iam_role \
  --policy-arn arn:aws:iam::aws:policy/AWSLambda_ReadOnlyAccess \
  --region eu-west-1
```

## Movimiento 2 — Permitir que el HTTP API invoque la función

```bash
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

API_ID=$(aws apigatewayv2 get-apis \
  --query "Items[?Name=='cmtr-iacp1ebx-iam-lp-apigwv2_api'].ApiId" \
  --output text --region eu-west-1)
# hd586xn8v4

aws lambda add-permission \
  --function-name cmtr-iacp1ebx-iam-lp-lambda \
  --statement-id apigateway-invoke \
  --action lambda:InvokeFunction \
  --principal apigateway.amazonaws.com \
  --source-arn "arn:aws:execute-api:eu-west-1:${ACCOUNT_ID}:${API_ID}/*/*" \
  --region eu-west-1
```

## Verificación por CLI

```bash
aws iam list-attached-role-policies --role-name cmtr-iacp1ebx-iam-lp-iam_role
aws lambda get-policy --function-name cmtr-iacp1ebx-iam-lp-lambda --region eu-west-1
```

`get-policy` mostró **dos** statements: uno preexistente `AllowExecutionFromAPIGateway` con `Principal: lambda.amazonaws.com` (parece un placeholder del sandbox, mal configurado — el Principal correcto para que API Gateway invoque una función es `apigateway.amazonaws.com`, no `lambda.amazonaws.com`) y el nuestro, `apigateway-invoke`, correctamente configurado. No fue necesario tocar el statement preexistente para que la tarea funcionara.

## Verificación — probando la API real

### Incidente: `{"message":"Not Found"}` al probar la URL base

```bash
aws apigatewayv2 get-apis \
  --query "Items[?Name=='cmtr-iacp1ebx-iam-lp-apigwv2_api'].ApiEndpoint" \
  --output text --region eu-west-1
# https://hd586xn8v4.execute-api.eu-west-1.amazonaws.com
```

Al abrir esa URL tal cual en el navegador, la respuesta fue `{"message":"Not Found"}`. No era un problema de permisos — las HTTP APIs de API Gateway v2 requieren que el path coincida con una **Route** configurada explícitamente. Se revisó con:

```bash
aws apigatewayv2 get-routes --api-id hd586xn8v4 --region eu-west-1
```
```json
{"Items": [{"RouteKey": "GET /get_list", "RouteId": "lykk4yh", ...}]}
```

**Fix**: la URL correcta era con el path de la route, no la base:
```
https://hd586xn8v4.execute-api.eu-west-1.amazonaws.com/get_list
```
```json
["cmtr-iacp1ebx-iam-lp-lambda"]
```

Respuesta correcta — confirma que ambos movimientos (permiso del rol para llamar `lambda:ListFunctions`, y permiso de API Gateway para invocar la función) quedaron bien configurados.
