# Resultados — Schedule EC2 Start/Stop with EventBridge and Lambda

**Estado:** ✅ Tarea completada y verificada por la plataforma (incluye bonus de uso de CLI, coeficiente 1.0)

## Resumen de los recursos configurados

| Recurso | Configuración |
|---|---|
| Regla `event_rule-start` | `cron(0 8 * * ? *)` (8:00 UTC), `ENABLED`, target Lambda con `Input: {"action":"start","tags":"tag:managed=no"}` |
| Regla `event_rule-stop` | `cron(0 20 * * ? *)` (20:00 UTC), `ENABLED`, target Lambda con `Input: {"action":"stop","tags":"tag:managed=no"}` |
| Instancia objetivo | `i-00fd0ec4dfc307c0a` (unmanaged, `managed=no`) — verificada manualmente con `stop`/`start` |

## Verificación automática de la plataforma

1. **Schedule Expression de la regla `start`** ✅ (`cron(0 8 * * ? *)`)
2. **Payload JSON de la regla `start`** ✅ (`action: start`, `tags: tag:managed=no`)
3. **Schedule Expression de la regla `stop`** ✅ (`cron(0 20 * * ? *)`)
4. **Payload JSON de la regla `stop`** ✅ (`action: stop`, `tags: tag:managed=no`)
5. **Bonus por uso de CLI** ✅ (coeficiente 1.0)

## Aprendizaje clave

Las reglas de EventBridge ya venían con el target correcto pero un cron placeholder (año 1970) y sin `Input`. Leer el código real de la Lambda fue indispensable: sin pasar `tags` explícitamente en el payload, la función habría operado sobre la instancia "managed" por defecto (variable de entorno `DEFAULT_TAGS`), no la "unmanaged" que pedía el enunciado.

## Recursos

Al finalizar se usó el botón **"Destroy Resources"** de la plataforma.
