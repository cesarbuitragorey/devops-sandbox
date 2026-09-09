# Resultados — Final Task: Implement Gitea Hosting Infrastructure on AWS

**Estado:** ✅ Tarea completada y verificada por la plataforma (8/8 checks aprobados) — **proyecto de cierre del bootcamp AWS DevOps.**

## Resumen de los recursos configurados

| Recurso | Configuración |
|---|---|
| Stack CloudFormation | `cmtr-iacp1ebx-final`, `CREATE_COMPLETE`, 30+ recursos |
| Red | VPC `cmtr-iacp1ebx-vpc`, 2 subnets públicas + 2 privadas (2 AZs), IGW, NAT Gateway, tablas de rutas pública/privada |
| Seguridad | 4 security groups (ALB:80, EC2:80/22, RDS:3306, EFS:2049), todos con referencias entre sí (no CIDRs abiertos salvo ALB/SSH) |
| Balanceo | ALB `cmtr-iacp1ebx-alb` (internet-facing) + Target Group `cmtr-iacp1ebx-tg` + Listener + Listener Rule, *stickiness* habilitado tras el incidente |
| Base de datos | RDS MySQL `giteadb`, `db.t3.micro`, privada |
| Almacenamiento compartido | EFS `cmtr-iacp1ebx-efs` con mount targets en ambas subnets privadas |
| Cómputo | Launch Template `cmtr-iacp1ebx-lt` (Amazon Linux 2023, Docker + Docker Compose + Gitea), ASG `cmtr-iacp1ebx-asg` (min 2 / max 4), rol `cmtr-iacp1ebx-role` + profile `cmtr-iacp1ebx-profile` |
| Autoscaling | Target tracking por `ALBRequestCountPerTarget`, umbral 10 req/s |
| Observabilidad | Dashboard `cmtr-iacp1ebx-dashboard` con RDS CPU/Connections, ALB HealthyHostCount/RequestCount, EFS ClientConnections |
| Aplicación | Gitea instalado, usuario `giteauser`, repositorio `awsgiteaproject` |

## Verificación automática de la plataforma

1. **Stack CloudFormation existe** ✅
2. **Status `CREATE_COMPLETE`** ✅
3. **Recursos del stack correctos** ✅ (VPC, LoadBalancer, SecurityGroups, FileSystem, InstanceProfile, DBInstance, ScalingPolicy)
4. **ASG con min/max correctos** ✅ (`2` / `4`)
5. **Gitea accesible vía DNS del ALB** ✅ (`200`)
6. **Repo de Gitea existe en EFS** ✅ (estructura de repo bare Git confirmada en `/gitea/git/repositories/giteauser/awsgiteaproject.git`)
7. **Instance Profile correcto adjunto a las EC2** ✅
8. **Dashboard de CloudWatch con las métricas correctas** ✅ (las 5 requeridas, con dimensiones dinámicas correctamente resueltas)

## Incidente clave y aprendizaje

Con 2 instancias del ASG compartiendo configuración vía EFS pero cada una ejecutando su propio proceso Gitea de forma independiente, hubo una ventana de inconsistencia: una instancia completó la instalación web antes que la otra arrancara su contenedor, dejando ambas en estados distintos (una funcional, otra sirviendo 404) detrás del mismo ALB sin *stickiness*. Se resolvió habilitando *sticky sessions* (cookie-based) en el Target Group y reiniciando ambos contenedores Docker vía SSM para forzar una relectura de la configuración ya sincronizada por EFS — un problema de coordinación multi-instancia inherente a "hornear" el estado de instalación en un archivo compartido en vez de usar un mecanismo de inicialización idempotente y explícito.

## Recursos

Al finalizar se usó el botón **"Destroy Resources"** de la plataforma.
