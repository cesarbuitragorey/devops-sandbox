# Resultados — Task 1: AWS IaC with Terraform: Creating Network Resources

**Estado:** ✅ Tarea completada y verificada por la plataforma (17/17 checks aprobados).

## Resumen de los recursos configurados

| Recurso | Configuración |
|---|---|
| VPC | `cmtr-iacp1ebx-01-vpc`, CIDR `10.10.0.0/16` |
| Subnet público A | `cmtr-iacp1ebx-01-subnet-public-a`, `eu-west-1a`, CIDR `10.10.1.0/24` |
| Subnet público B | `cmtr-iacp1ebx-01-subnet-public-b`, `eu-west-1b`, CIDR `10.10.3.0/24` |
| Subnet público C | `cmtr-iacp1ebx-01-subnet-public-c`, `eu-west-1c`, CIDR `10.10.5.0/24` |
| Internet Gateway | `cmtr-iacp1ebx-01-igw`, adjunto a la VPC |
| Route table | `cmtr-iacp1ebx-01-rt`, asociada a los 3 subnets, ruta `0.0.0.0/0 → IGW` |
| Backend | Local (implícito, sin bloque `backend` en la configuración) |

## Verificación automática de la plataforma (17/17)

1. Clonado del repositorio ✅
2. Backend local (no definido) ✅
3. Archivos requeridos presentes (`main.tf`, `variables.tf`, `vpc.tf`, `versions.tf`, `outputs.tf`, `terraform.tfvars`) ✅
4. `required_version` correcto (`>= 1.5.7`) ✅
5. Todas las variables con `description` y `type` ✅
6. `terraform init` exitoso ✅
7. Código formateado (`terraform fmt`) ✅
8. `terraform validate` exitoso ✅
9. `terraform plan` generado correctamente ✅
10. El plan lista exactamente los recursos esperados ✅
11. `terraform apply` exitoso (9 recursos creados) ✅
12. VPC creada con el CIDR correcto ✅
13. Subnet público A: CIDR, VPC y AZ correctos ✅
14. Subnet público B: CIDR, VPC y AZ correctos ✅
15. Subnet público C: CIDR, VPC y AZ correctos ✅
16. Internet Gateway creado y adjunto a la VPC correcta ✅
17. Route table creada, asociada a los 3 subnets, con ruta al IGW ✅

## Recursos

Al finalizar se usó el botón **"Destroy Resources"** de la plataforma.
