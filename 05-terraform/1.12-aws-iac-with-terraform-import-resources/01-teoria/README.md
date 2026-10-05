# Teoría — Task 1.12: AWS IaC with Terraform: Import Resources

## Import es el camino inverso a `state mv`: un recurso real sin dueño pasa a tener uno

En el lab 1.10 un recurso cambió de un state a otro; aquí el recurso (la política IAM) existía en AWS pero **no estaba en ningún state**: el `state list` inicial salió vacío. `terraform import` toma un recurso real, lo identifica por su ID (para `aws_iam_policy`, su ARN) y lo registra en el state bajo una dirección del código (`aws_iam_policy.custom_policy`). Igual que `state mv`, no escribe nada en AWS: solo crea la asociación "este bloque de código = este recurso real".

## `import` solo toca el state; el código lo escribes tú

Esta es la limitación central del comando clásico: importa el recurso al state, pero **no genera la definición en HCL**. Por eso el orden del enunciado es: primero leer cómo es la política real (`aws iam get-policy` y `get-policy-version`) y luego escribir en `resources.tf` un bloque que coincida con sus atributos. Cualquier discrepancia (descripción, path, un `Action` de más o de menos) aparecerá como cambio en el siguiente `plan`: Terraform propondría *modificar* la política real para que coincida con el código. En esta task el objetivo era el contrario: ajustar el **código** al recurso existente, nunca el recurso al código.

## El `plan` antes del import muestra por qué hace falta importar

Se corrió `plan` justo antes del import y propuso **crear** la política (`1 to add`). Esa es la señal de un recurso declarado pero sin dueño en el state: si en ese momento se hubiera hecho `apply`, Terraform habría intentado crear una política con un nombre que ya existe y habría fallado (IAM no permite dos políticas con el mismo nombre en la misma cuenta). El import es lo que convierte ese `1 to add` en `No changes`.

## Importar con el ARN, no con el nombre

Para `aws_iam_policy` el ID de import es el **ARN completo** (`arn:aws:iam::<cuenta>:policy/<nombre>`), no el nombre. Obtenerlo con `aws iam list-policies --scope Local --query "Policies[?PolicyName=='…'].Arn"` evita escribirlo a mano (y equivocarse en el número de cuenta). `--scope Local` limita la búsqueda a políticas gestionadas por el cliente, excluyendo las miles de políticas administradas por AWS.

## Qué atributos comparar para que el plan salga limpio

Tres atributos son los que hay que alinear: `name`, `description` y el documento de `policy`. El documento se declara con `jsonencode(...)`, y Terraform compara el JSON semánticamente (no por texto), así que el orden de las claves o los espacios no importan; sí importan los valores. `path` quedó en su valor por defecto (`/`), que coincidía con el real, por lo que no hizo falta declararlo.

## No hacer `destroy` después de un import

A diferencia de los labs de creación, aquí no se destruye nada al terminar: tras el import, la política **ya es gestionada por Terraform**, y un `terraform destroy` la eliminaría de AWS. La condición de éxito del enunciado es justamente lo contrario ("the imported IAM policy must remain unchanged in AWS").

## Nota sobre alternativas modernas

Desde Terraform 1.5 existe el bloque declarativo `import { to = ...  id = ... }`, que permite importar como parte del `plan`/`apply` y hasta generar el código con `-generate-config-out`. El enunciado pide expresamente el comando `terraform import`, por eso se usó el flujo clásico; ambos llevan al mismo resultado en el state.
