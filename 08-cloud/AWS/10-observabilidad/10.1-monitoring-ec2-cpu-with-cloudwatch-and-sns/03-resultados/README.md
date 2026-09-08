# Resultados — Monitoring EC2 CPU with CloudWatch and SNS for Notification

**Estado:** ✅ Tarea completada y verificada por la plataforma (9/9 checks aprobados)

## Resumen de los recursos configurados

| Recurso | Configuración |
|---|---|
| Security Group | `cmtr-iacp1ebx-sg`, SSH (22) abierto |
| Instancia EC2 | `cmtr-iacp1ebx-instance` (`i-0d97e847401b8d91d`), Amazon Linux 2023, `t3.micro`, IP pública, UserData con `stress --cpu 2 --timeout 1800s` |
| SNS Topic | `cmtr-iacp1ebx-sns`, suscripción email `cesar_buitrago@epam.com` confirmada |
| Alarma | `cmtr-iacp1ebx-alarm`, `CPUUtilization` ≥ 60%, `GreaterThanOrEqualToThreshold`, período 300s, acción → SNS |

## Verificación automática de la plataforma

1. **1 instancia EC2 corriendo con el nombre correcto** ✅
2. **Estado y status checks de la instancia** ✅
3. **UserData instala y corre `stress` correctamente** ✅ (`sudo dnf install -y stress` + `sudo stress --cpu 2 --timeout 1800s`)
4. **SNS topic con el nombre correcto** ✅
5. **1 suscripción en el topic** ✅
6. **Protocolo/endpoint de la suscripción** ✅ (`email` → `cesar_buitrago@epam.com`)
7. **Suscripción confirmada** ✅ (`PendingConfirmation: false`)
8. **Parámetros de la alarma correctos** ✅ (`GreaterThanOrEqualToThreshold`, `Threshold: 60`, acción SNS correcta)
9. **Dimensión `InstanceId` de la alarma correcta** ✅

## Incidentes clave

- UserData sin `sudo` funcionaba pero no pasaba la validación textual del checker → se relanzó la instancia con el script corregido.
- `ComparisonOperator` inicial (`GreaterThanThreshold`) no coincidía con lo esperado (`GreaterThanOrEqualToThreshold`) → corregido con un nuevo `put-metric-alarm`.

## Recursos

Los recursos de este lab se destruyen automáticamente al completar la tarea (según nota del enunciado), sin necesidad de "Destroy Resources" manual.
