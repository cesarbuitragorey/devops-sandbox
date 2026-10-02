# Teoría — Task 1.9: AWS IaC with Terraform: Use Data Discovery

## Tres formas de referenciar infraestructura existente, y cuándo usar cada una

El módulo ya recorrió tres enfoques para consumir recursos que Terraform no creó en esta configuración:

1. **Data sources por nombre/filtro contra la API de AWS** (tasks 1.2, 1.4, 1.5): consultan directamente a AWS.
2. **`terraform_remote_state`** (task 1.7): lee los *outputs* que otra configuración de Terraform publicó en su archivo de state. Requiere que esa configuración exista y exponga esos outputs.
3. **Data discovery con filtros y tags** (esta task): igual que (1), pero el criterio de búsqueda es un tag (`Name`) en vez de un ID o un nombre de recurso conocido de antemano.

La diferencia práctica entre (1) y (3) es de grado: descubrir por tag desacopla la configuración de los IDs reales, que cambian cada vez que la infraestructura se recrea. Mientras el tag `Name` se mantenga estable, la misma configuración funciona en cualquier cuenta o región.

## `aws_ami` con `most_recent` y un patrón de nombre

En vez de fijar un AMI ID (que caduca y cambia por región), `data "aws_ami"` busca imágenes por propietario (`owners = ["amazon"]`) y por patrón de nombre (`al2023-ami-2023.*-x86_64`), y `most_recent = true` se queda con la más nueva que cumpla. Sin `most_recent`, si el filtro devuelve varias imágenes Terraform falla con "multiple results". Es la contrapartida de lo que se hizo en labs anteriores con el parámetro público de SSM: ambos resuelven "el último Amazon Linux 2023", uno consultando el catálogo de AMIs y el otro un parámetro que AWS mantiene actualizado.

## Filtros que deben resolver a un único resultado

`aws_vpc`, `aws_subnet` y `aws_security_group` (singulares) fallan si el filtro devuelve más de un recurso, igual que ya había pasado con `aws_subnet` en la task 1.2. Aquí se acotó cada búsqueda por tag `Name` y, para subnet y security group, además por `vpc_id` de la VPC ya descubierta — así la búsqueda queda anidada (VPC → sus subnets/SGs) y es mucho menos probable colisionar con recursos homónimos de otra VPC.

## El checker también valida qué data sources se usan

Dos checks de esta task son nuevos respecto a las anteriores: verifica que el plan solo cree tipos de recurso permitidos y que solo lea data sources aprobados (`aws_vpc`, `aws_subnet`, `aws_security_group`, `aws_ami`). Es decir, no basta con que el resultado final sea correcto: la *forma* de llegar a él (descubrir con los data sources pedidos, no con otros atajos como `aws_ssm_parameter` para el AMI) también se evalúa. Por eso en esta task el AMI se descubrió con `aws_ami`, no con el parámetro SSM que sí se había usado en las tasks 1.2, 1.7 y 1.8.

## Aplicar lo aprendido de la 1.7: nada de literales sueltos

El dueño del AMI (`amazon`) y el patrón de nombre (`al2023-ami-2023.*-x86_64`) se definieron como variables con su valor en `terraform.tfvars`, no como literales en `data.tf`. La task 1.7 había mostrado que el checker de "hardcoded" marca cualquier string literal que no venga de una variable; aplicarlo desde el inicio evitó repetir ese fallo (15/15 en el primer intento).
