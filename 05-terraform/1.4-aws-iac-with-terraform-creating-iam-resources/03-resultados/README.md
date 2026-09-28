# Resultados — Task 1.4: AWS IaC with Terraform: Creating IAM Resources

**Estado:** ✅ Tarea completada y verificada por la plataforma (16/16 checks aprobados, primer intento).

## Resumen de los recursos configurados

| Recurso | Configuración |
|---|---|
| IAM group | `cmtr-iacp1ebx-iam-group` (sin tags — no soportado por AWS para grupos) |
| IAM policy | `cmtr-iacp1ebx-iam-policy`, solo `s3:PutObject`/`s3:DeleteObject` sobre `cmtr-iacp1ebx-bucket-1790635311/*`, tag `Project=cmtr-iacp1ebx` |
| IAM role | `cmtr-iacp1ebx-iam-role`, trust hacia `ec2.amazonaws.com`, policy adjunta, tag `Project=cmtr-iacp1ebx` |
| IAM instance profile | `cmtr-iacp1ebx-iam-instance-profile`, asociado al rol, tag `Project=cmtr-iacp1ebx` |

## Verificación automática de la plataforma (16/16)

1. Clonado del repositorio ✅
2. Backend local (no definido) ✅
3. Ausencia de nombres hardcodeados ✅
4. `required_version` correcto (`>= 1.5.7`) ✅
5. Todas las variables con `description` y `type` ✅
6. Código formateado ✅
7. `terraform init` exitoso ✅
8. `terraform plan` generado correctamente ✅
9. El plan lista exactamente los recursos esperados ✅
10. `terraform validate` exitoso ✅
11. `terraform apply` exitoso (5 recursos creados) ✅
12. Existencia de `iam.tf` ✅
13. IAM group con el nombre correcto ✅
14. IAM policy con el nombre correcto ✅
15. IAM role con el nombre correcto ✅
16. IAM instance profile con el nombre correcto ✅

## Recursos

Al finalizar se usó el botón **"Destroy Resources"** de la plataforma.
