# Resultados — Task 1.2: AWS IaC with Terraform: Create Resources for SSH Authentication

**Estado:** ✅ Tarea completada y verificada por la plataforma (15/15 checks aprobados).

## Resumen de los recursos configurados

| Recurso | Configuración |
|---|---|
| Key pair | `cmtr-iacp1ebx-keypair`, clave pública ed25519 pasada vía `TF_VAR_ssh_key` |
| EC2 | `cmtr-iacp1ebx-ec2`, AMI Amazon Linux 2023 (resuelto vía SSM), `t3.micro` |
| Red | Subnet público existente (`cmtr-iacp1ebx-vpc`, referenciado vía data source), IP pública asignada |
| Seguridad | Security group existente `cmtr-iacp1ebx-sg` (referenciado vía data source) |
| Tags | `Project=epam-tf-lab`, `ID=cmtr-iacp1ebx` en ambos recursos |

## Verificación automática de la plataforma (15/15)

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
12. EC2 `cmtr-iacp1ebx-ec2` creada y en estado `running` ✅
13. Security group `cmtr-iacp1ebx-sg` adjunto a la instancia ✅
14. Key pair `cmtr-iacp1ebx-keypair` existe ✅
15. IP pública asignada a la instancia ✅

Adicionalmente, se verificó manualmente el objetivo 10 (conexión SSH con la llave privada local) antes de destruir la infraestructura de prueba.

## Recursos

Al finalizar se usó el botón **"Destroy Resources"** de la plataforma.
