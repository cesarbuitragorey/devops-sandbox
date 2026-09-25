# Teoría — Task 1.2: AWS IaC with Terraform: Create Resources for SSH Authentication

## Referenciar infraestructura pre-creada con data sources en vez de recrearla

La plataforma ya provisionó la VPC (`cmtr-iacp1ebx-vpc`), los subnets públicos y el security group (`cmtr-iacp1ebx-sg`) antes de empezar la task. En vez de declarar esos recursos de nuevo (lo que además fallaría, porque ya existen con esos nombres), se usaron `data "aws_vpc"`, `data "aws_subnet"` y `data "aws_security_group"` para leer sus IDs reales y referenciarlos desde el `aws_instance`. Este es el caso de uso central de los data sources: leer infraestructura que Terraform no gestiona directamente (ya sea de otra configuración, o —como aquí— creada fuera de Terraform por completo) sin intentar tomar control de su ciclo de vida.

## `aws_subnet` (singular) exige que el filtro resuelva a exactamente un resultado

A diferencia de `aws_subnets` (plural, devuelve una lista), el data source `aws_subnet` falla si el filtro no resuelve a un único subnet. Como la VPC pre-creada tiene varios subnets públicos (uno por AZ), fue necesario acotar el filtro con una Availability Zone explícita (`var.availability_zone`) además de `map-public-ip-on-launch = true`, en vez de filtrar solo por VPC — de lo contrario Terraform habría lanzado un error de "multiple results found" durante el `plan`.

## Secreto pasado por variable de entorno, nunca por archivo

El enunciado pide explícitamente que la clave pública SSH no quede hardcodeada ni en el repositorio. Se resolvió declarando `ssh_key` como una variable sin `default` y sin entrada en `terraform.tfvars` (que sí contiene el resto de los valores no sensibles) — el único lugar donde existe es la variable de entorno `TF_VAR_ssh_key`, exportada en la terminal antes de correr `terraform apply`. La convención `TF_VAR_<nombre>` es la forma nativa de Terraform de inyectar el valor de cualquier variable declarada sin tocar código ni archivos versionados.

## El checker de la plataforma también corre `terraform apply` en el pipeline de verificación

A diferencia de la task anterior (que solo verificaba recursos ya aplicados vía CLI de AWS), acá el campo "Your generated public key" del formulario de verificación existe porque, al no estar la clave en el repo, el propio pipeline de verificación necesita que se la proporcionen para poder exportar su propio `TF_VAR_ssh_key` y correr `apply` de forma reproducible — confirma que el flujo de "secreto fuera del repo" funciona de punta a punta, no solo localmente.
