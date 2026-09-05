# Resultados — Manage the Processing of Snapshots of an Instance

**Estado:** ⏳ **Pendiente — no ha pasado el check de la plataforma.** Configuración verificada como correcta por CLI en dos sandboxes distintos; el check #1 del "Check" automatizado sigue sin reconocerla.

## Resumen de lo configurado (verificado por CLI, no por el checker de la plataforma)

| Recurso | Configuración |
|---|---|
| SSM Document `cmtr-iacp1ebx-mysql-prepost-doc` | Tipo `Command`, parámetro `command` con `allowedValues: ["pre-script","post-script"]`, lógica basada en `systemctl is-active mysqld` |
| Política DLM | `State: ENABLED`, `TargetTags: Name=cmtr-iacp1ebx-ec2-s-instance`, `RetainRule.Count: 3`, `CreateRule.Interval: 1/HOURS`, `Scripts` con `Stages: ["PRE","POST"]` apuntando al documento anterior, tag `Name=cmtr-iacp1ebx-policy` |

## Resultado del "Check" de la plataforma (dos intentos, dos sandboxes distintos)

```
* 1. Checks if the DLM policy with name cmtr-iacp1ebx-policy assigned to existing instance.
  actual_output (std_out): ""   (esperado: que contenga "cmtr-iacp1ebx-ec2-s-instance")
  status_code: 0 (sin error) | stderr: "" (sin error)
* 2-6. Skipped, first resolve test(s): 1
* 7. CLI usage check — Skipped
```

Mismo resultado exacto en:
- **Sandbox 1** (cuenta `182399681840`, instancia `i-000396135b4558fa6`, política `policy-0f4a57e91d9ad79e3`, luego recreada como `policy-04968548b23ce4456`)
- **Sandbox 2**, tras un "Restart task" completo en la plataforma (cuenta `242201273488`, instancia `i-08abbe6ccb6cff3cb`, política `policy-02ecdc6eea21ff633`)

## Diagnósticos descartados

- ✅ Tag de la instancia vs. `TargetTags` de la política: **idénticos byte a byte** (verificado con `xxd` en ambos sandboxes)
- ✅ Región: fijada de forma persistente en `~/.aws/config` (`aws configure set region eu-west-1`), no solo por variable de entorno
- ✅ Sin políticas de DLM duplicadas o en conflicto (`get-lifecycle-policies` sin filtro muestra solo la nuestra)
- ✅ `ResourceTypes: INSTANCE` correcto en ambos lados
- ✅ Recrear la política desde cero (delete + create) en el mismo sandbox: mismo resultado
- ✅ Recrear todo el entorno desde cero (Restart Task, cuenta distinta): mismo resultado exacto

## Próximos pasos al retomar

1. Conectarse a la instancia vía `aws ssm start-session` y revisar si `aws configure get region` / `~/.aws/config` **dentro de la instancia** tiene la región fijada — hipótesis de que el checker podría ejecutarse en ese contexto en vez de desde CloudShell.
2. Esperar el tiempo suficiente (posiblemente >1h) a que DLM ejecute su primer snapshot programado, y confirmar si el check #1 depende de esa evidencia de ejecución real en vez de solo la configuración de la política.
3. Si ninguna de las dos explica el fallo, considerar que el check #1 de este lab específico tiene un bug en la plataforma, y reportarlo si es posible.

## Recursos

Los recursos de ambos sandboxes ya fueron destruidos o reemplazados sin llegar a "Destroy Resources" manual explícito en este punto (task interrumpido en progreso).
