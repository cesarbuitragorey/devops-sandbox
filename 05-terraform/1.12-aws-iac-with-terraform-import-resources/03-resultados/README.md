# Resultados — Task 1.12: AWS IaC with Terraform: Import Resources

**Estado:** ✅ Tarea completada y verificada por la plataforma (7/7 checks aprobados, primer intento).

## Resumen del resultado

| Elemento | Estado final |
|---|---|
| Recurso en el código | `aws_iam_policy.custom_policy` en `resources.tf`, coincide con la política real |
| Recurso en el state remoto | Importado (`terraform import` con el ARN) |
| ARN | `arn:aws:iam::913524907044:policy/cmtr-iacp1ebx-iam-policy` |
| `terraform plan` antes del import | Proponía crear la política (1 to add) |
| `terraform plan` después del import | *No changes* |
| Política IAM en AWS | Intacta |

## Verificación automática de la plataforma (7/7)

1. Clonado del repositorio ✅
2. Código formateado ✅
3. `terraform init` exitoso (backend S3 remoto) ✅
4. `terraform validate` exitoso ✅
5. `terraform plan`: sin cambios ✅
6. `resources.tf` existe y no está vacío ✅
7. El ID del recurso no cambió respecto al original ✅

## Recursos

En este lab no se destruyó infraestructura con `terraform destroy` (la política importada debía permanecer intacta). Al finalizar se usó el botón **"Destroy Resources"** de la plataforma.
