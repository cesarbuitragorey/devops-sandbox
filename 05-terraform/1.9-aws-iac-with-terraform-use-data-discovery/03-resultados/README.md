# Resultados — Task 1.9: AWS IaC with Terraform: Use Data Discovery

**Estado:** ✅ Tarea completada y verificada por la plataforma (15/15 checks aprobados, primer intento).

## Resumen de los recursos configurados

| Recurso | Configuración |
|---|---|
| Data source `aws_vpc` | Descubre `cmtr-iacp1ebx-vpc` por tag `Name` |
| Data source `aws_subnet` | Descubre `cmtr-iacp1ebx-public-subnet-1` por tag `Name` dentro de la VPC |
| Data source `aws_security_group` | Descubre `cmtr-iacp1ebx-sg` por tag `Name` dentro de la VPC |
| Data source `aws_ami` | Último Amazon Linux 2023 (`most_recent`, propietario `amazon`, patrón de nombre) |
| EC2 | `cmtr-iacp1ebx-instance`, `t3.micro`, tag `Project=cmtr-iacp1ebx`, todos los valores de infraestructura vienen de data sources |

## Verificación automática de la plataforma (15/15)

1. Clonado del repositorio ✅
2. Backend local (no definido) ✅
3. `required_version` correcto (`>= 1.5.7`) ✅
4. Todas las variables con `description` y `type` ✅
5. `terraform init` exitoso ✅
6. Código formateado ✅
7. `terraform validate` exitoso ✅
8. `terraform plan` generado correctamente ✅
9. El plan solo crea tipos de recurso permitidos ✅
10. El plan solo lee data sources aprobados ✅
11. `terraform apply` exitoso (1 recurso creado) ✅
12. EC2 `cmtr-iacp1ebx-instance` creada y en estado `running` ✅
13. Security group `cmtr-iacp1ebx-sg` adjunto a la instancia ✅
14. Instancia creada en la VPC `cmtr-iacp1ebx-vpc` ✅
15. Instancia creada en el subnet público `cmtr-iacp1ebx-public-subnet-1` ✅

## Recursos

Al finalizar se usó el botón **"Destroy Resources"** de la plataforma.
