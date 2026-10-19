# Resultados — Task 1.14: AWS IaC with Terraform: Modules

**Estado:** ✅ Tarea completada y verificada por la plataforma (26/26 checks aprobados, quinto intento).

## Resumen de la solución

| Módulo | Recursos (tipos) |
|---|---|
| `network` | `aws_vpc`, `aws_subnet` (×3, `for_each`), `aws_internet_gateway`, `aws_route_table`, `aws_route_table_association` (×3) |
| `network_security` | `aws_security_group` (×3: SSH, HTTP público, HTTP privado) con reglas `ingress`/`egress` inline |
| `application` | `aws_launch_template`, `aws_autoscaling_group`, `aws_autoscaling_attachment`, `aws_lb`, `aws_lb_target_group`, `aws_lb_listener` y el data source `aws_ami` |

Plan final: **18 recursos**. Salidas de la raíz: `load_balancer_dns_name` y `vpc_id`.

## Verificación automática de la plataforma (26/26)

1. Clonado del repositorio ✅
2. Backend por defecto (local) ✅
3. Sin valores ni nombres hardcodeados ✅
4. `required_version` correcto (`>= 1.5.7`) ✅
5. Todas las variables con `description` y `type` ✅
6. Código formateado ✅
7. `terraform init` exitoso (módulos `network_security`, `network`, `application`) ✅
8. `terraform plan` generado correctamente (18 a crear) ✅
9. Tipos de recurso permitidos en el módulo `application` ✅
10. Tipos de recurso permitidos en el módulo `network` ✅
11. Tipos de recurso permitidos en el módulo `network_security` ✅
12. `terraform validate` exitoso ✅
13. Existencia de los módulos y archivos requeridos ✅
14. `terraform apply` exitoso (18 recursos creados) ✅
15. VPC `cmtr-iacp1ebx-vpc` con CIDR `10.10.0.0/16` ✅
16–18. Subnets públicas `a`/`b`/`c` con CIDR y zona correctos ✅
19. Internet Gateway creado y adjunto a la VPC ✅
20. Route table asociada a las subnets con ruta al IGW ✅
21. Security group SSH existe con el nombre correcto ✅
22. Regla SSH desde el rango permitido (2 CIDRs) ✅
23. Security group HTTP público existe con el nombre correcto ✅
24. Regla HTTP desde el rango permitido (2 CIDRs) ✅
25. Security group HTTP privado existe con el nombre correcto ✅
26. Balanceo de carga: UUIDs distintos entre respuestas ✅

## Historial de intentos

| Intento | Resultado | Causa / corrección |
|---|---|---|
| 1 | Falló desde el check 11 | `aws_security_group_rule` no permitido en `network_security` → reglas inline |
| 2 | 1–25 ✅, falló el 26 | La página no mostraba el UUID de la máquina (bloques del enunciado vacíos al copiar) → formato `This message was generated on instance … UUID …` + health check corto |
| 3 y 4 | El 26 siguió fallando | La plataforma conservaba el despliegue anterior: instancias viejas sin UUID |
| (diagnóstico) | — | Instancias terminadas con `terminate-instance-in-auto-scaling-group`; el ASG las reemplazó con el template nuevo |
| 5 | 26/26 ✅ | Despliegue completo desde cero con UUIDs distintos |

## Recursos

Al finalizar se usó el botón **"Destroy Resources"** de la plataforma.
