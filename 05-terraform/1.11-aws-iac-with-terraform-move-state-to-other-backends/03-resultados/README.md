# Resultados — Task 1.11: AWS IaC with Terraform: Move State to Other Backends

**Estado:** ✅ Tarea completada y verificada por la plataforma (7/7 checks aprobados, primer intento).

## Resumen del resultado

| Elemento | Estado final |
|---|---|
| Backend del código (`providers.tf`) | Bucket nuevo `cmtr-iacp1ebx-backend-new-bucket-1791205963`, key `tf_code.tfstate`, región `eu-west-1` |
| State en el bucket nuevo | Contiene `aws_iam_policy.custom_policy` |
| Diferencia con el state original | Solo el campo `lineage` (regenerado por Terraform en el destino) |
| `terraform plan` | *No changes* |
| Política IAM en AWS | Intacta, mismo ARN (`resource-move-demo-policy`) |

## Verificación automática de la plataforma (7/7)

1. Clonado del repositorio ✅
2. Código formateado ✅
3. `terraform init` exitoso (contra el backend nuevo) ✅
4. `terraform validate` exitoso ✅
5. `terraform plan`: sin cambios ✅
6. El ID de la política es idéntico: la migración es correcta ✅
7. `resources.tf` existe ✅

## Recursos

En este lab no se destruyó infraestructura con `terraform destroy` (la política debía permanecer intacta). Al finalizar se usó el botón **"Destroy Resources"** de la plataforma.
