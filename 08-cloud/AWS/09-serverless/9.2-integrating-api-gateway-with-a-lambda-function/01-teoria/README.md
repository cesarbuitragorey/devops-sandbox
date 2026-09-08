# Teoría — Integrating API Gateway with a Lambda Function

## Route Key: el "qué" de una ruta HTTP API

En una API Gateway HTTP API (v2), un `Route` define un patrón `MÉTODO /ruta` (`RouteKey`, ej. `GET /contacts`) y un `Target` que apunta a una integración (`integrations/<id>`). Ambos campos son independientes: se puede tener una integración perfectamente configurada apuntando a la Lambda correcta, pero si el `RouteKey` no coincide con la ruta que el cliente solicita (en este lab, decía `GET /wrong-path` en vez de `GET /contacts`), la API Gateway simplemente responde `404 Not Found` — nunca llega a invocar el backend, porque ni siquiera encuentra una ruta que matchee la request entrante.

## `AWS_PROXY` integration: la Lambda recibe y devuelve el control HTTP completo

Con `IntegrationType: AWS_PROXY`, API Gateway no transforma la solicitud/respuesta — pasa el evento HTTP completo (método, headers, query params, body) tal cual a la Lambda, y espera que la función devuelva un objeto con `statusCode`, `headers` y `body` (como string, típicamente JSON serializado). Es el modo más simple de exponer una función como API, porque toda la lógica de la respuesta HTTP vive en el código de la función, no en configuración de la API Gateway.

## El permiso de invocación es un recurso separado de la integración

Configurar la integración (`AWS_PROXY` apuntando al ARN de la Lambda) no es suficiente para que la invocación funcione — API Gateway necesita permiso IAM **basado en recursos** en la propia función Lambda (`lambda:AddPermission` con `Principal: apigateway.amazonaws.com`, condicionado al ARN del API/ruta específica vía `SourceArn`). Sin ese permiso, la API Gateway recibe un error de autorización al intentar invocar la función, incluso con la integración y la ruta perfectamente configuradas — son dos mecanismos de seguridad independientes (la integración define "a dónde", el resource policy define "quién puede invocar").

## El stage determina la URL real del endpoint

Cuando el stage de una HTTP API **no** se llama `$default`, su nombre se convierte en un segmento obligatorio de la URL (`https://<api-id>.execute-api.<region>.amazonaws.com/<stage-name>/<ruta>`) — a diferencia del stage `$default`, que no aparece en la URL. Con `AutoDeploy: true` (el valor por defecto para HTTP APIs), cualquier cambio en rutas/integraciones se despliega automáticamente al stage sin necesidad de un paso de "deploy" manual explícito (a diferencia de las REST APIs v1, donde sí se requiere `create-deployment` de forma explícita tras cada cambio).
