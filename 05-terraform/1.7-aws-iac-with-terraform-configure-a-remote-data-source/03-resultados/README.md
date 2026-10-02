# Resultados — Task 1.7: AWS IaC with Terraform: Configure a Remote Data Source

**Estado:** ✅ Tarea completada y verificada por la plataforma (15/15 checks aprobados, tercer intento).

## Resumen de los recursos configurados

| Recurso | Configuración |
|---|---|
| Data source | `data.terraform_remote_state.base_infra` — backend S3, bucket/key/region desde variables |
| EC2 | `aws_instance.this`, en el subnet público de la Landing Zone, AMI Amazon Linux 2023 (vía SSM) |
| Security group | `cmtr-iacp1ebx-ec2-sg` — leído del remote state, sin recrearlo |
| Tags | `Terraform=true`, `Project=cmtr-iacp1ebx` |

## Verificación automática de la plataforma (15/15)

1. Clonado del repositorio ✅
2. `terraform_remote_state` correctamente configurado ✅
3. Ausencia de nombres hardcodeados ✅ (tras mover la ruta del parámetro SSM a una variable)
4. `required_version` correcto (`>= 1.5.7`) ✅
5. Todas las variables con `description` y `type` ✅
6. Código formateado ✅
7. `terraform init` exitoso ✅
8. `terraform plan` generado correctamente ✅
9. El plan lista exactamente los recursos esperados ✅
10. `terraform validate` exitoso ✅
11. `terraform apply` exitoso (1 recurso creado) ✅
12. Archivos requeridos presentes (`variables.tf`, `terraform.tfvars`, `data.tf`, `compute.tf`) ✅
13. EC2 corriendo con los tags requeridos ✅
14. Security group correcto (del remote state) adjunto a la instancia ✅
15. Instancia creada en la VPC correcta (del remote state) ✅

## Intentos previos fallidos

1. **Intentos 1 y 2:** fallaron por no haber comiteado/subido el código de esta task todavía (el repo remoto no tenía `variables.tf`/`data.tf`/`compute.tf`).
2. **Intento 3 (parcial):** con el código ya subido, falló solo el check de "ausencia de hardcoded resources" por la ruta literal del parámetro SSM del AMI en `compute.tf`.

## Recursos

Al finalizar se usó el botón **"Destroy Resources"** de la plataforma.
