# Teoría — Schedule EC2 Start/Stop with EventBridge and Lambda

## EventBridge Rule: `ScheduleExpression` + `Target.Input` son configuraciones separadas

Una regla de EventBridge con un target Lambda tiene dos piezas configurables independientemente: **cuándo** dispara (`ScheduleExpression`, vía `put-rule`) y **qué payload** envía al invocar el target (`Input`, vía `put-targets`). Es posible tener una regla con schedule correcto pero sin `Input` (la Lambda se invoca con `{}` vacío) o viceversa — en este lab, ambas reglas ya existían con un target apuntando al Lambda correcto, pero con un cron placeholder inútil (`cron(* * ? * * 1970)`, año 1970 — nunca dispara) y **sin** `Input` configurado en absoluto.

## Leer el código antes de adivinar el formato del payload

El enunciado pedía "refer to the Lambda code to determine the required input format" — la función esperaba `event['action']` (`"start"`/`"stop"`) y opcionalmente `event['tags']` (string de pares `key=value` separados por coma, con el prefijo `tag:` en el nombre). Si `tags` no se provee, cae a la variable de entorno `DEFAULT_TAGS` (`tag:managed=yes` en este lab) — es decir, **sin especificar `tags` explícitamente en el payload, la función operaría sobre la instancia equivocada** (la "managed", no la "unmanaged" que pedía el enunciado). Leer el código fue indispensable para no automatizar una acción sobre el recurso incorrecto.

## Formato de `Input` en `put-targets`: JSON como string

El parámetro `Input` de un target de EventBridge se pasa como un **string** que contiene JSON serializado (no como un objeto JSON anidado directamente en la estructura del comando) — de ahí la necesidad de escapar las comillas internas (`\"action\":\"start\"...`) al construirlo desde la shell.

## Sobreescribir el default de una función sin tocar su código

En vez de modificar la variable de entorno `DEFAULT_TAGS` de la Lambda (lo cual afectaría CUALQUIER invocación futura, incluidas invocaciones manuales sin `tags`), la forma correcta de dirigir esta automatización específica hacia la instancia "unmanaged" es pasar `tags` explícitamente en el `Input` de cada regla — el comportamiento por defecto de la función queda intacto para otros casos de uso, y cada trigger de EventBridge decide su propio target de forma autocontenida.
