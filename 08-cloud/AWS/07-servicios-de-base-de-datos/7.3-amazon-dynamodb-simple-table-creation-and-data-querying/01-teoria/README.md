# Teoría — Amazon DynamoDB Simple Table Creation and Data Querying

## DynamoDB como base de datos NoSQL sin schema fijo

A diferencia de RDS, DynamoDB no exige definir por adelantado todos los atributos de un item — solo la **partition key** (y opcionalmente una sort key) son obligatorias al crear la tabla. Cada item puede tener atributos completamente distintos entre sí, siempre que incluya la clave de partición. En este lab, la tabla se crea solo con `id` (String) como partition key, y el resto de atributos (`Name`, `Active`, `Roles`) se definen recién al insertar el item, no en el esquema de la tabla.

## Tipos de atributo en el formato JSON de bajo nivel de DynamoDB

La AWS CLI para DynamoDB requiere que cada valor se anote explícitamente con su tipo de dato usando claves de un solo o dos caracteres:
- `S` — String (`{"S": "Dean Winchester"}`)
- `BOOL` — Boolean (`{"BOOL": true}`)
- `L` — List (`{"L": [ {...}, {...} ]}`), cuyos elementos a su vez llevan su propio tipo anidado (aquí, cada elemento de `Roles` es un `{"S": "..."}`)

Este formato ("DynamoDB JSON") es más verboso que un JSON plano porque permite representar sin ambigüedad los tipos nativos de DynamoDB (incluyendo `N` para números, `B` para binario, `SS`/`NS`/`BS` para sets), algo que un JSON estándar no distingue por sí solo (ej. no se puede diferenciar un string numérico de un número real sin esta anotación).

## `PAY_PER_REQUEST` vs. capacidad aprovisionada

Al crear la tabla con `--billing-mode PAY_PER_REQUEST`, DynamoDB escala automáticamente la capacidad de lectura/escritura según la demanda real, sin necesidad de fijar `ReadCapacityUnits`/`WriteCapacityUnits` de antemano — ideal para cargas de trabajo impredecibles o, como en este lab, de volumen mínimo y esporádico.

## `get-item` vs. `query`/`scan`

`get-item` es la operación más eficiente para recuperar un item cuando ya se conoce su clave primaria completa (aquí, el valor exacto de `id`) — hace una búsqueda directa O(1), a diferencia de `query` (que busca por partition key, permitiendo condiciones sobre la sort key) o `scan` (que recorre toda la tabla). Para este lab, donde solo existe un item y se conoce su `id`, `get-item` es la elección natural.
