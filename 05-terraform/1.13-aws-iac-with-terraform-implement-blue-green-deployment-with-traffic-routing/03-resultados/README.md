# Resultados — Task 1.13: AWS IaC with Terraform: Implement Blue-Green Deployment with Traffic Routing

**Estado:** ✅ Tarea completada y verificada por la plataforma (14/14 checks aprobados, primer intento).

## Resumen de los recursos configurados

| Recurso | Configuración |
|---|---|
| ALB | `cmtr-iacp1ebx-lb`, público, en los dos subnets públicos, SG `cmtr-iacp1ebx-sg-lb` |
| Listener | HTTP:80, `forward` ponderado con `blue_weight=100` / `green_weight=0` |
| Target groups | `cmtr-iacp1ebx-blue-tg`, `cmtr-iacp1ebx-green-tg` (HTTP:80, health check `/`) |
| Launch templates | `cmtr-iacp1ebx-blue-template`, `cmtr-iacp1ebx-green-template` (httpd + página por entorno) |
| ASGs | `cmtr-iacp1ebx-blue-asg`, `cmtr-iacp1ebx-green-asg` (1 deseada / 1 mín / 2 máx), cada uno en su target group |
| Tags | `Terraform=true`, `Project=cmtr-iacp1ebx` |

## Pruebas manuales previas a la verificación

| Prueba | Resultado |
|---|---|
| 100/0, 10 peticiones | 10 × `Blue Environment` |
| 50/50, justo tras el `apply` | 10 × `Blue` (el cambio aún no se había propagado en el ALB) |
| 50/50, tras esperar 45 s, 20 peticiones | 10 × `Blue`, 10 × `Green` |
| Volver a 100/0 y `terraform plan` | *No changes* |

## Verificación automática de la plataforma (14/14)

1. Clonado del repositorio ✅
2. Backend por defecto (local) ✅
3. Sin valores ni nombres hardcodeados ✅
4. `required_version` correcto (`>= 1.5.7`) ✅
5. Todas las variables con `description` y `type` ✅
6. Código formateado ✅
7. `terraform init` exitoso ✅
8. `terraform plan` generado correctamente (8 recursos a crear) ✅
9. El plan solo crea tipos de recurso permitidos ✅
10. `terraform validate` exitoso ✅
11. `terraform apply` exitoso (8 recursos creados) ✅
12. Check Blue: 5 de 5 peticiones devolvieron `Blue Environment` ✅
13. `terraform apply` con pesos cambiados hacia Green ✅
14. Check Green: 5 de 5 peticiones devolvieron `Green Environment` ✅

## Recursos

Al finalizar se usó el botón **"Destroy Resources"** de la plataforma.
