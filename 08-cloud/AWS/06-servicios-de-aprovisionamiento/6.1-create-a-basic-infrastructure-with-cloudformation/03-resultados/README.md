# Resultados — Create a Basic Infrastructure with CloudFormation

**Estado:** ✅ Tarea completada y verificada por la plataforma (7/7 checks aprobados)

## Resumen de los recursos configurados

| Recurso | Configuración |
|---|---|
| Stack | `cmtr-iacp1ebx-basic-infra`, `CREATE_COMPLETE` |
| VPC | `cmtr-iacp1ebx-vpc`, `10.0.0.0/16` |
| Subnets | `cmtr-iacp1ebx-subnet1` (`eu-west-1a`), `cmtr-iacp1ebx-subnet2` (`eu-west-1b`), ambas públicas |
| Red | Internet Gateway + 2 tablas de rutas públicas (`0.0.0.0/0` → IGW) |
| Security Group | `cmtr-iacp1ebx-sg` — 22/tcp y 80/tcp abiertos |
| Rol EC2 | `cmtr-iacp1ebx-role` con `AmazonSSMManagedInstanceCore` |
| Instancias | `cmtr-iacp1ebx-instance1` (`i-06e210ce7d8633310`, "Hello from Region eu-west-1a"), `cmtr-iacp1ebx-instance2` (`i-0566f3af897db98a3`, "Hello from Region eu-west-1b") |
| Tag `Maintainer` | `cmtr-iacp1ebx-maintainer` en todos los recursos, vía parámetro |

## Verificación automática de la plataforma

1. **Stack existe** ✅
2. **Stack en `CREATE_COMPLETE`** ✅
3. **Parámetro `Maintainer` fijado correctamente** ✅
4. **Webserver corriendo en instance1 (`eu-west-1a`)** ✅ — devuelve `Hello from Region eu-west-1a`
5. **Webserver corriendo en instance2 (`eu-west-1b`)** ✅ — devuelve `Hello from Region eu-west-1b`
6. **Webserver de instance1 accesible desde Internet** ✅ — `200`
7. **Webserver de instance2 accesible desde Internet** ✅ — `200`

## Nota sobre verificación manual

Se intentó verificar manualmente vía `aws ssm start-session` antes del check de la plataforma, pero el CLI local no tenía instalado el Session Manager plugin (`SessionManagerPlugin is not found`). No fue necesario resolverlo: el check automatizado de la plataforma validó el contenido real de cada servidor web (vía SSM Run Command o similar) sin depender de una sesión interactiva manual.

## Recursos

Al finalizar se usó el botón **"Destroy Resources"** de la plataforma.
