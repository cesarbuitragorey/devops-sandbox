# Resultados — Task 1.3: AWS IaC with Terraform: Create an Object Storage

**Estado:** ✅ Tarea completada y verificada por la plataforma (14/14 checks aprobados, primer intento).

## Resumen de los recursos configurados

| Recurso | Configuración |
|---|---|
| S3 bucket | `cmtr-iacp1ebx-bucket-1790338985`, tag `Project=cmtr-iacp1ebx` |
| Acceso público | Bloqueado explícitamente vía `aws_s3_bucket_public_access_block` (4/4 flags en `true`) |

## Verificación automática de la plataforma (14/14)

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
11. `terraform apply` exitoso (2 recursos creados) ✅
12. Bucket `cmtr-iacp1ebx-bucket-1790338985` existe ✅
13. Tag `Project=cmtr-iacp1ebx` presente ✅
14. Bucket privado, sin acceso público ✅

## Recursos

Al finalizar se usó el botón **"Destroy Resources"** de la plataforma.
