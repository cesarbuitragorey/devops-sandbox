# Resultados — Amazon DynamoDB Simple Table Creation and Data Querying

**Estado:** ✅ Tarea completada y verificada por la plataforma (5/5 checks aprobados)

## Resumen de los recursos configurados

| Recurso | Configuración |
|---|---|
| Tabla | `cmtr-dynamodb-create-table-iacp1ebx-mytable`, partition key `id` (String), billing `PAY_PER_REQUEST` |
| Item | `id: cmtr-iacp1ebx`, `Name: "Dean Winchester"` (S), `Active: true` (BOOL), `Roles: ["Incedent Analyst", "Impala Manager"]` (L de S) |

## Verificación automática de la plataforma

1. **Tabla existe** ✅
2. **Partition key `id` con valor `cmtr-iacp1ebx` creada** ✅
3. **Atributo booleano `Active = true`** ✅
4. **Atributo string `Name = Dean Winchester`** ✅
5. **Atributo lista `Roles` con los valores correctos** ✅

## Recursos

Al finalizar se usó el botón **"Destroy Resources"** de la plataforma.
