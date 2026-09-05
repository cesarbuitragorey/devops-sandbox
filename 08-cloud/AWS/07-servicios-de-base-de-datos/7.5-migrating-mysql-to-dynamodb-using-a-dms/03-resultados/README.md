# Resultados — Migrating MySQL to DynamoDB Using a DMS

**Estado:** ✅ Tarea completada y verificada por la plataforma

## Resumen de los recursos configurados

| Recurso | Configuración |
|---|---|
| Endpoint origen | `cmtr-iacp1ebx-dms-mtdm-source-endpoint`, MySQL, IP pública `34.245.135.195`, DB `imdb` |
| Endpoint destino | `cmtr-iacp1ebx-dms-mtdm-target-endpoint`, DynamoDB, rol `cmtr-iacp1ebx-dms-mtdm-dynamodb-access` |
| Tarea 01 | `cmtr-iacp1ebx-dms-mtdm-historical-migration01` — vista `movies`, mskey `DETL\|categoria\|orden` |
| Tarea 02 | `cmtr-iacp1ebx-dms-mtdm-historical-migration02` — tabla `title_akas`, mskey `REGN\|region` |
| Tarea 03 | `cmtr-iacp1ebx-dms-mtdm-historical-migration03` — tabla `title_ratings`, mskey `RTNG` |
| Lista de migración | 23 IDs únicos de películas (`tt0027125` ... `tt0117057`), obtenidos explorando la fuente MySQL |
| Tabla destino final | `movies` (DynamoDB), 23 items (estado tras la última tarea, `DROP_AND_CREATE`) |

## Verificación automática de la plataforma

1. **Endpoint origen creado** ✅
2. **Endpoint destino creado** ✅
3. **Las 3 tareas de replicación creadas** ✅
4. **Todos los items migrados a DynamoDB** ✅ (23 — tras corregir el comportamiento de `TargetTablePrepMode`, ver práctica)

## Aprendizaje clave

Las 3 tareas comparten la misma tabla destino (`movies`). Con el `TargetTablePrepMode` por defecto (`DROP_AND_CREATE`), cada tarea posterior borra lo cargado por la anterior — el checker de la plataforma esperaba precisamente ese comportamiento (estado final = solo la última tarea ejecutada, 23 items de `ratings`), no una acumulación aditiva de las 3 fuentes bajo un patrón adjacency-list completo.

## Recursos

Al finalizar se usó el botón **"Destroy Resources"** de la plataforma.
