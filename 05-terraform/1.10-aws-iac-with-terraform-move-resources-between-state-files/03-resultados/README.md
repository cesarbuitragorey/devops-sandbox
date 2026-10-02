# Resultados — Task 1.10: AWS IaC with Terraform: Move Resources between State Files

**Estado:** ✅ Tarea completada y verificada por la plataforma (13/13 checks aprobados, primer intento).

## Resumen del resultado

| Elemento | Estado final |
|---|---|
| `aws_iam_policy.custom_policy` en `tf_code_1.tfstate` | Ya no aparece |
| `aws_iam_policy.custom_policy` en `tf_code_2.tfstate` | Presente, mismo ID/ARN (`resource-move-demo-policy`) |
| `tf_code_1/resources.tf` | Vacío (recurso removido) |
| `tf_code_2/resources.tf` | Contiene la definición del recurso, idéntica a la original |
| `terraform plan` en ambos directorios | *No changes* |
| Política en AWS | Intacta (no se recreó ni modificó) |

## Verificación automática de la plataforma (13/13)

1. Clonado del repositorio ✅
2. `terraform init` en `tf_code_1` ✅
3. Código formateado en `tf_code_1` ✅
4. `terraform validate` en `tf_code_1` ✅
5. `terraform plan` en `tf_code_1`: sin cambios ✅
6. `terraform init` en `tf_code_2` ✅
7. Código formateado en `tf_code_2` ✅
8. `terraform validate` en `tf_code_2` ✅
9. `terraform plan` en `tf_code_2`: sin cambios ✅
10. `tf_code_1/resources.tf` ya no contiene el recurso movido ✅
11. `resources.tf` existe en `tf_code_2` ✅
12. El ID del recurso no cambió respecto al original ✅
13. El recurso ya no está en el state de origen ✅

## Recursos

En este lab no se destruyó infraestructura con `terraform destroy` (la política debía permanecer intacta). Al finalizar se usó el botón **"Destroy Resources"** de la plataforma.
