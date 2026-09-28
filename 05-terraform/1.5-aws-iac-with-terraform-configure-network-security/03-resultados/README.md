# Resultados — Task 1.5: AWS IaC with Terraform: Configure Network Security

**Estado:** ✅ Tarea completada y verificada por la plataforma (18/18 checks aprobados, primer intento).

## Resumen de los recursos configurados

| Recurso | Configuración |
|---|---|
| SG SSH | `cmtr-iacp1ebx-ssh-sg` — ingress `22/tcp` e ICMP desde `allowed_ip_range` |
| SG HTTP público | `cmtr-iacp1ebx-public-http-sg` — ingress `80/tcp` e ICMP desde `allowed_ip_range` |
| SG HTTP privado | `cmtr-iacp1ebx-private-http-sg` — ingress `8080/tcp` e ICMP con `source_security_group_id` = SG HTTP público |
| Attachments | SSH+HTTP público → instancia pública; SSH+HTTP privado → instancia privada (vía `aws_network_interface_sg_attachment`, sin tocar el SG de testing) |
| Tags | `Project=cmtr-iacp1ebx` en los 3 security groups |

## Verificación automática de la plataforma (18/18)

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
11. `terraform apply` exitoso (13 recursos creados) ✅
12. SG SSH existe con el nombre correcto ✅
13. Reglas SSH + ICMP correctas ✅
14. SG HTTP público existe con el nombre correcto ✅
15. Reglas HTTP + ICMP correctas ✅
16. SG HTTP privado usa el SG público como source ✅
17. Nginx accesible en el puerto 80 de la instancia pública ✅
18. Todos los archivos requeridos existen ✅

## Recursos

Al finalizar se usó el botón **"Destroy Resources"** de la plataforma.
