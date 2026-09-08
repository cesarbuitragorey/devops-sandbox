# Resultados — Integrating API Gateway with a Lambda Function

**Estado:** ✅ Tarea completada y verificada por la plataforma (incluye bonus de uso de CLI, coeficiente 1.0)

## Resumen de los recursos configurados

| Recurso | Configuración |
|---|---|
| Ruta | `kmp2ny1`, `RouteKey` corregido de `GET /wrong-path` a `GET /contacts` |
| Integración | `cdhnuyp`, `AWS_PROXY` hacia `cmtr-iacp1ebx-api-gwlp-lambda-contacts` (ya estaba correcta) |
| Permiso Lambda | `apigateway.amazonaws.com` autorizado a invocar, condicionado al ARN de la ruta `/contacts` |
| Endpoint verificado | `https://q5qrkkb6tl.execute-api.eu-west-1.amazonaws.com/cmtr-iacp1ebx-api-gwlp-apigwv2_stage/contacts` |

## Verificación automática de la plataforma

1. **Endpoint disponible y devuelve el payload correcto** ✅ (3 contactos, `elmaherring@unq.com` confirmado)
2. **Bonus por uso de CLI** ✅ (coeficiente 1.0)

## Recursos

Al finalizar se usó el botón **"Destroy Resources"** de la plataforma.
