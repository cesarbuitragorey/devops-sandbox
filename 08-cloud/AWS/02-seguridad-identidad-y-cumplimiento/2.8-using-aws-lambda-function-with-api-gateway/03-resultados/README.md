# Resultados — Using AWS Lambda Function with API Gateway

**Estado:** ✅ Tarea completada y verificada por la plataforma (2/2 checks aprobados)

## Resumen de los recursos configurados

| Recurso | Configuración |
|---|---|
| `cmtr-iacp1ebx-iam-lp-iam_role` | `AWSLambda_ReadOnlyAccess` (AWS managed) adjuntada |
| `cmtr-iacp1ebx-iam-lp-lambda` | Resource-based policy: statement `apigateway-invoke` permitiendo invocación desde el API Gateway específico |
| `cmtr-iacp1ebx-iam-lp-apigwv2_api` | Sin cambios de configuración — solo se usó su ID/endpoint |

## Verificación automática de la plataforma

1. **Invocación de Lambda vía API Gateway funciona** ✅
   ```json
   ["cmtr-iacp1ebx-iam-lp-lambda"]
   ```
2. **Bono por uso de CLI** ✅ — coeficiente 1.0

## Verificación manual (navegador)

`https://hd586xn8v4.execute-api.eu-west-1.amazonaws.com/get_list` → `["cmtr-iacp1ebx-iam-lp-lambda"]`

## Recursos destruidos

Al finalizar se usó el botón **"Destroy Resources"** de la plataforma — la función, el rol y el API Gateway configurados ya no existen fuera de este registro.
