# Práctica — Integrating API Gateway with a Lambda Function

## Enunciado de la tarea

> Integrate a pre-existing Lambda function with an existing API Gateway route so that `GET /contacts` returns a fixed list of 3 contacts.

**Región:** `eu-west-1` — Cuenta `585685714791`

**Recursos pre-creados:** HTTP API `q5qrkkb6tl`, ruta `kmp2ny1`, función `cmtr-iacp1ebx-api-gwlp-lambda-contacts` (código ya desplegado).

**Entorno real usado:** CLI local (Git Bash).

---

## Movimiento 1 — Diagnóstico del estado inicial

```bash
aws apigatewayv2 get-api --api-id q5qrkkb6tl
aws apigatewayv2 get-route --api-id q5qrkkb6tl --route-id kmp2ny1
aws lambda get-function --function-name cmtr-iacp1ebx-api-gwlp-lambda-contacts
```
Hallazgos:
- El `RouteKey` de la ruta era `GET /wrong-path` (deliberadamente incorrecto), no `GET /contacts`.
- La ruta ya tenía un `Target` apuntando a una integración (`integrations/cdhnuyp`).
- Descargando el código del Lambda (URL S3 firmada del propio `get-function`) se confirmó que `contacts.py` ya devuelve exactamente la lista de 3 contactos esperada — no hacía falta tocar el código.

```bash
aws apigatewayv2 get-integration --api-id q5qrkkb6tl --integration-id cdhnuyp
```
Confirmó que la integración (`AWS_PROXY`, `IntegrationUri` apuntando al ARN correcto de la función) ya estaba correctamente configurada.

## Movimiento 2 — Corregir la ruta

```bash
aws apigatewayv2 update-route \
  --api-id q5qrkkb6tl \
  --route-id kmp2ny1 \
  --route-key "GET /contacts"
```

## Incidente: `curl` al endpoint devuelve `404 Not Found`

Tras corregir la ruta, `curl https://q5qrkkb6tl.execute-api.eu-west-1.amazonaws.com/contacts` seguía fallando. Dos causas distintas:

1. **Falta el permiso de invocación (resource policy) en la Lambda**:
```bash
aws lambda get-policy --function-name cmtr-iacp1ebx-api-gwlp-lambda-contacts
# ResourceNotFoundException — no existe ninguna policy de recursos aún
```
**Fix**:
```bash
aws lambda add-permission \
  --function-name cmtr-iacp1ebx-api-gwlp-lambda-contacts \
  --statement-id apigateway-invoke \
  --action lambda:InvokeFunction \
  --principal apigateway.amazonaws.com \
  --source-arn "arn:aws:execute-api:eu-west-1:585685714791:q5qrkkb6tl/*/*/contacts"
```

2. **El stage no es `$default`**:
```bash
aws apigatewayv2 get-stages --api-id q5qrkkb6tl
# StageName: "cmtr-iacp1ebx-api-gwlp-apigwv2_stage" (con AutoDeploy: true)
```
La URL correcta debe incluir el nombre del stage.

## Verificación

```bash
curl -s https://q5qrkkb6tl.execute-api.eu-west-1.amazonaws.com/cmtr-iacp1ebx-api-gwlp-apigwv2_stage/contacts
```
Devolvió exactamente la lista de 3 contactos especificada en el enunciado.
