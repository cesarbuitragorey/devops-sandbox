# Resultados — Task 1.6: AWS IaC with Terraform: Form TF Output

**Estado:** ✅ Tarea completada y verificada por la plataforma (29/29 checks aprobados, primer intento).

## Resumen de los recursos configurados

| Recurso | Configuración |
|---|---|
| VPC | `cmtr-iacp1ebx-01-vpc`, CIDR `10.10.0.0/16` |
| Subnets públicos | `-a`/`-b`/`-c` en `eu-west-1a`/`b`/`c`, CIDRs `10.10.1.0/24`, `10.10.3.0/24`, `10.10.5.0/24` |
| Internet Gateway | `cmtr-iacp1ebx-01-igw`, adjunto a la VPC |
| Route table | `cmtr-iacp1ebx-01-rt`, asociada a los 3 subnets, ruta `0.0.0.0/0 → IGW` |
| Outputs | `vpc_id`, `vpc_cidr`, `public_subnet_ids`, `public_subnet_cidr_block`, `public_subnet_availability_zone`, `internet_gateway_id`, `routing_table_id` |

## Verificación automática de la plataforma (29/29)

1. Clonado del repositorio ✅
2. Backend local (no definido) ✅
3. `required_version` correcto (`>= 1.5.7`) ✅
4. Todas las variables con `description` y `type` ✅
5. `terraform init` exitoso ✅
6. Código formateado ✅
7. `terraform validate` exitoso ✅
8. `terraform plan` generado correctamente ✅
9. El plan lista exactamente los recursos esperados ✅
10. `terraform apply` exitoso (9 recursos creados) ✅
11. VPC con CIDR correcto ✅
12–14. Los 3 subnets con CIDR y VPC correctos ✅
15. IGW creado y adjunto a la VPC correcta ✅
16. Route table asociada a los 3 subnets, con ruta al IGW ✅
17–19. Los 3 subnets con AZ correcta ✅
20. Archivos requeridos presentes ✅
21–22. Outputs presentes y no vacíos ✅
23–29. Nombres/CIDRs/AZs de VPC, subnets, IGW y route table verificados individualmente ✅

## Recursos

Al finalizar se usó el botón **"Destroy Resources"** de la plataforma.
