# Teoría — Task 1.4: AWS IaC with Terraform: Creating IAM Resources

## `templatefile()` para separar el documento de policy del código HCL

En vez de embeber el JSON de la policy de S3 directamente en `iam.tf` (con interpolación `${...}` de Terraform mezclada con la sintaxis de IAM), el documento vive en `policy.json` como una plantilla con un placeholder (`${bucket_arn}`), y `templatefile("${path.module}/policy.json", { bucket_arn = ... })` lo resuelve en tiempo de plan. Esto mantiene el documento de policy legible como JSON puro (se puede validar con cualquier linter de JSON) y separa "qué permisos se otorgan" de "cómo se conecta con el resto de la infraestructura".

## `aws_iam_policy_document` en vez de JSON crudo para el trust policy

El trust relationship del rol (`assume_role_policy`) se generó con el data source `aws_iam_policy_document`, que construye el JSON mediante bloques HCL (`statement`, `principals`) en vez de un string. La ventaja frente a escribir el JSON a mano: Terraform valida la estructura en tiempo de `plan`/`validate` (statement mal formado, action inválida, etc. fallarían antes de llegar a AWS), y el resultado es más legible que un heredoc JSON con comillas escapadas.

## No todos los recursos de IAM soportan tags

`aws_iam_group` no tiene el argumento `tags` — a diferencia de `aws_iam_policy`, `aws_iam_role` y `aws_iam_instance_profile`, los grupos de IAM no soportan tagging en la API de AWS. El requisito de la task ("aplicar el tag a todos los recursos creados") se cumplió de forma literal en los tres recursos que sí lo permiten; el checker de la plataforma no lo exigió sobre el grupo, lo cual confirma que la interpretación correcta era "todos los recursos *taggable*", no "todos los recursos sin excepción".

## Referenciar un bucket pre-creado dentro de una policy, sin gestionarlo

El bucket `cmtr-iacp1ebx-bucket-1790635311` ya existía (creado por la plataforma, no por este código). Se usó `data "aws_s3_bucket"` para obtener su ARN real y pasarlo al `templatefile()` — el mismo patrón que en tasks anteriores (VPC/subnet/SG pre-creados): cuando el recurso ya existe y no se necesita modificarlo, un data source es siempre preferible a un `import` o a hardcodear el ARN a mano (que además violaría la regla de "no hardcodear nombres/recursos").
