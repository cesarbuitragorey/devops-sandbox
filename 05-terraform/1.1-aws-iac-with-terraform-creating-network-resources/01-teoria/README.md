# Teoría — Task 1: AWS IaC with Terraform: Creating Network Resources

## `for_each` sobre un `map(object(...))` en vez de tres bloques de recurso repetidos

Los 3 subnets públicos (`cmtr-iacp1ebx-01-subnet-public-a/b/c`) se modelaron como una única variable `public_subnets` de tipo `map(object({ name, cidr_block, availability_zone }))`, y un solo `resource "aws_subnet" "public"` con `for_each = var.public_subnets`. Esto evita triplicar el bloque de recurso (uno por AZ) y, sobre todo, evita hardcodear los nombres — que era uno de los requisitos explícitos de la task. Las `route_table_association` se generaron con el mismo patrón, iterando sobre `aws_subnet.public` (`for_each = aws_subnet.public`), en vez de escribir tres asociaciones manuales referenciando cada subnet por su nombre de recurso.

## Ninguna variable con `default`

La task pide explícitamente que los nombres de recursos vengan de variables (o de `locals` generados dinámicamente) y prohíbe usar la propiedad `default` en las variables — precisamente para forzar que todos los valores no sensibles vivan en `terraform.tfvars` y no queden "escondidos" como default dentro de `variables.tf`. Se cumplió dejando todas las variables (`aws_region`, `vpc_name`, `vpc_cidr`, `internet_gateway_name`, `route_table_name`, `public_subnets`) sin `default`, con sus valores reales únicamente en `terraform.tfvars`.

## Backend local implícito

No se declaró ningún bloque `backend` dentro de `terraform {}` — Terraform usa el backend local por defecto (state en `terraform.tfstate`, en el mismo directorio). El checker de la plataforma verificó esto explícitamente ("Backend is not defined").

## El campo "Repository folder" del formulario de verificación

A diferencia de las tasks anteriores del bootcamp (CloudFormation, verificadas contra la cuenta de AWS vía CLI), esta task se verifica clonando el repositorio Git real y corriendo el flujo de Terraform (`init`/`fmt`/`validate`/`plan`/`apply`) dentro de él. El formulario de verificación tiene un campo `Repository folder` que le indica al verificador en qué subcarpeta del repo están los `.tf` — esto permite reutilizar un repo de documentación existente (`devops-sandbox`) sin necesitar un repo dedicado por task, siempre que los archivos `main.tf`, `variables.tf`, `vpc.tf`, `versions.tf`, `outputs.tf` y `terraform.tfvars` estén juntos en esa carpeta.

## `terraform destroy` antes de la verificación

Como la plataforma redespliega la infraestructura desde cero en cada corrida de verificación (clona el repo y corre su propio `apply`), es necesario destruir manualmente la infraestructura que uno probó localmente antes de disparar la verificación — de lo contrario se generarían recursos duplicados con el mismo nombre (o, en el caso de la VPC/CIDR, un conflicto de superposición de rangos) entre la infraestructura de prueba local y la que crea el verificador.
