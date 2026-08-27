# Teoría — IAM Policies con Condiciones

## El bloque `Condition` en una política de IAM

Además de `Effect`, `Action` y `Resource`, una declaración de política puede incluir un bloque `Condition` que evalúa el contexto de la request (no el recurso en sí) para decidir si aplica o no. Estructura general:

```json
"Condition": {
  "<operador-de-condición>": {
    "<clave-de-condición>": "<valor(es)>"
  }
}
```

Este lab usa dos combinaciones clásicas:

| Operador | Clave de condición | Uso en este lab |
|---|---|---|
| `IpAddress` | `aws:SourceIp` | Restringir según el rango CIDR desde donde se origina la llamada a la API |
| `StringEquals` | `aws:RequestedRegion` | Restringir según la región de AWS que la llamada está apuntando |

`aws:SourceIp` y `aws:RequestedRegion` son **claves de condición globales** — disponibles en cualquier política de IAM sin importar el servicio, a diferencia de claves específicas de un servicio (ej. `s3:prefix`).

## `Deny` explícito vs. ausencia de `Allow`

En la evaluación de políticas de IAM, el orden de precedencia es:
1. Por defecto, todo está **denegado implícitamente**.
2. Un `Allow` explícito en cualquier política aplicable lo habilita.
3. Un `Deny` explícito en **cualquier** política (incluyendo SCP) siempre gana, sin importar cuántos `Allow` existan en otras políticas.

Este lab pide agregar políticas **Deny explícito** condicionadas, sobre un rol que "tiene un conjunto de permisos predefinido, que no debe modificarse" — es decir, en vez de tocar los `Allow` existentes, se le suman restricciones adicionales que actúan como un veto condicional por encima de cualquier permiso que ya tenga.

## Instance Profiles y roles de EC2

Una instancia EC2 obtiene credenciales de AWS a través de su **IAM Instance Profile**, que a su vez contiene un **IAM Role**. Dentro de la instancia, el CLI/SDK obtiene automáticamente credenciales temporales consultando el servicio de metadatos de la instancia (`http://169.254.169.254/...`) — no hace falta configurar nada manualmente, y las políticas adjuntas a ese rol aplican exactamente igual que si fueran de un usuario o rol asumido explícitamente.

**Importante para pruebas**: las políticas con condiciones como `aws:SourceIp` solo se evalúan contra la IP real desde la que sale la llamada a la API. Si se prueban esas políticas desde una sesión distinta (ej. CloudShell del administrador, en vez de una sesión abierta *dentro* de la instancia EC2 vía Session Manager), el resultado no será representativo — ni el rol correcto está en uso, ni el IP de origen coincide.

## Alcance del `Resource` en acciones "globales" de un servicio

Algunas acciones de un servicio no operan sobre un recurso específico, sino sobre la cuenta completa — por ejemplo, `s3:ListAllMyBuckets` (listar todos los buckets de la cuenta) siempre tiene como recurso implícito `"*"`, nunca un ARN de bucket puntual. Si una política `Deny` limita su `Resource` a un ARN de bucket específico (ej. `arn:aws:s3:::mi-bucket`), esa condición **no cubre** acciones cuyo alcance es siempre `"*"`, aunque el `Action` (ej. `s3:List*`) sí las incluya por patrón. Para bloquear ese tipo de acciones hay que usar `Resource: "*"` en la declaración.
