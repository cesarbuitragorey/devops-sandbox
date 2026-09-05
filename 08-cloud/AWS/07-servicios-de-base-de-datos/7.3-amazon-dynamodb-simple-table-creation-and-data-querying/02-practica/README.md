# Práctica — Amazon DynamoDB Simple Table Creation and Data Querying

## Enunciado de la tarea

> Create a DynamoDB table, insert a record with sample data, and query that record.

**Región:** `eu-west-1` — Cuenta `535002879489`

**Objetivos:**
1. Tabla `cmtr-dynamodb-create-table-iacp1ebx-mytable`, partition key `id` (String)
2. Item con `id = cmtr-iacp1ebx`, `Name` (String) = `Dean Winchester`, `Active` (Boolean) = `true`, `Roles` (List de strings) = `["Incedent Analyst", "Impala Manager"]`

**Entorno real usado:** CLI local (Git Bash en Windows).

---

## Movimiento 1 — Crear la tabla

```bash
aws dynamodb create-table \
  --table-name cmtr-dynamodb-create-table-iacp1ebx-mytable \
  --attribute-definitions AttributeName=id,AttributeType=S \
  --key-schema AttributeName=id,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST

aws dynamodb wait table-exists --table-name cmtr-dynamodb-create-table-iacp1ebx-mytable
```

### Incidente: el pager (`less`) de la AWS CLI en Git Bash traga los comandos siguientes

Tras el `create-table`, la salida quedó abierta en `less` (pager por defecto de la CLI), y los comandos pegados a continuación (`wait`, el heredoc de `item.json`) se interpretaron como teclas de navegación de `less` en vez de ejecutarse — mostró la ayuda de `less` y rompió el heredoc (`unexpected EOF while looking for matching`). **Fix**: desactivar el pager de forma persistente:
```bash
aws configure set cli_pager ""
```

## Movimiento 2 — Insertar el item

```bash
cat > item.json << 'EOF'
{
  "id": {"S": "cmtr-iacp1ebx"},
  "Name": {"S": "Dean Winchester"},
  "Active": {"BOOL": true},
  "Roles": {"L": [{"S": "Incedent Analyst"}, {"S": "Impala Manager"}]}
}
EOF

aws dynamodb put-item \
  --table-name cmtr-dynamodb-create-table-iacp1ebx-mytable \
  --item file://item.json
```
Nota: el string `"Incedent Analyst"` (con ese typo) se dejó exactamente como lo especifica el enunciado de la tarea.

## Verificación

```bash
aws dynamodb get-item \
  --table-name cmtr-dynamodb-create-table-iacp1ebx-mytable \
  --key '{"id": {"S": "cmtr-iacp1ebx"}}'
```
Devolvió el item completo con los 4 atributos correctos (`id`, `Name`, `Active`, `Roles`).
