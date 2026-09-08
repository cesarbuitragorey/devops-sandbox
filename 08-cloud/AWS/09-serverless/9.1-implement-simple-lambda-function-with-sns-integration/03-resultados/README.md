# Resultados — Implement Simple Lambda Function with SNS Integration

**Estado:** ✅ Tarea completada y verificada por la plataforma (6/6 checks aprobados)

## Resumen de los recursos configurados

| Recurso | Configuración |
|---|---|
| SNS Topic | `cmtr-iacp1ebx-sns` |
| SQS Queue | `cmtr-iacp1ebx-sqs`, suscrita al topic con queue policy que permite `sns.amazonaws.com` |
| Suscripción email | `cesar_buitrago@epam.com`, confirmada |
| Rol IAM | `cmtr-iacp1ebx-lambda_sns_role` (`AmazonSNSFullAccess` + `AWSLambdaBasicExecutionRole`) |
| Lambda | `cmtr-iacp1ebx-lambda`, Python 3.12, consulta IPinfo y publica en SNS |

## Verificación automática de la plataforma

1. **Lambda existe** ✅
2. **SNS topic existe** ✅
3. **SQS queue existe** ✅
4. **Email y SQS suscritos al topic** ✅
5. **Lambda invocable, devuelve 200** ✅
6. **Mensaje publicado en SNS y recibido en SQS con `ip_address`/`city` correctos** ✅ (`8.8.8.8` → `Mountain View`)

## Recursos

Al finalizar se usó el botón **"Destroy Resources"** de la plataforma.
