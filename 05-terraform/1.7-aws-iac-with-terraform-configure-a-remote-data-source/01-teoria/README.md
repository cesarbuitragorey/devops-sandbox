# Teoría — Task 1.7: AWS IaC with Terraform: Configure a Remote Data Source

## `terraform_remote_state` para consumir outputs de otra configuración

A diferencia de labs anteriores donde se usaban data sources como `aws_vpc`/`aws_subnet`/`aws_security_group` (consultando la API de AWS directamente por filtros), aquí la referencia a la Landing Zone se hace a través de `terraform_remote_state`, que lee el **archivo de state** de otra configuración de Terraform (almacenado en S3) y expone sus `outputs` bajo `data.terraform_remote_state.<nombre>.outputs.<output>`. La diferencia práctica: esto solo funciona si esa otra configuración ya definió esos valores como outputs explícitos — no es una consulta genérica a la API, es un contrato entre dos configuraciones de Terraform que se acuerdan de antemano qué outputs se comparten.

## El checker de "no hardcoded" también detecta strings literales que no son IDs de recursos

En el primer intento de verificación, el checker marcó como "hardcoded" la ruta del parámetro SSM (`/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64`) usada para resolver el AMI — a pesar de que técnicamente no es un ID de recurso AWS (no es un `vpc-...`/`subnet-...`/`sg-...`), sino solo el *path* de un parámetro público. La lección: la regla "no hardcodear" en estos checkers automatizados suele implementarse como una búsqueda de *cualquier string literal* en los archivos `.tf` que no venga de una variable, no una lista específica de patrones de ID de AWS. La solución fue moverlo a una variable (`ami_ssm_parameter_name`) con su valor en `terraform.tfvars`, igual que el resto de la configuración no sensible — consistente con la regla general del módulo, aunque el enunciado de esta task en particular solo mencionaba explícitamente los IDs de VPC/subnet/SG.

## Repetir la verificación sin haber subido el código todavía

Antes de este fix, la verificación falló dos veces con exactamente el mismo error ("Remote state data source is missing", "Required file variables.tf is missing") — la causa no fue el `Repository folder` (que sí estaba bien puesto), sino que el código de esta task nunca se había comiteado ni pusheado al repo todavía. Confirmar `git status` fue lo que reveló el problema real: los checks fallaban porque el checker clonaba un repo que simplemente no tenía esos archivos, no porque hubiera un error de configuración en el Terraform en sí.
