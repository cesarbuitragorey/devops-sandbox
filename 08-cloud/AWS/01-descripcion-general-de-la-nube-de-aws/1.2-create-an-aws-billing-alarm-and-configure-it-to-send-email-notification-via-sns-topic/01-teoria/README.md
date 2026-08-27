# Teoría — Alarma de facturación con CloudWatch + SNS

## AWS Billing & Cost Management

AWS publica el gasto acumulado de la cuenta como una métrica de CloudWatch (`EstimatedCharges`, namespace `AWS/Billing`). Para que esa métrica exista hay que **habilitar las alertas de facturación** (Billing Preferences → "Receive Billing Alerts") — un ajuste de la cuenta, no un recurso que se cree con `create-*`.

**Detalle importante**: la métrica de billing y cualquier alarma de CloudWatch que la use **deben crearse en la región `us-east-1`**, sin importar en qué región operen normalmente los demás recursos. Esto es una particularidad de AWS: los datos de facturación son globales pero solo se exponen como métrica de CloudWatch en `us-east-1`.

## Amazon SNS (Simple Notification Service)

Servicio de mensajería pub/sub:

- **Topic (tema)**: canal lógico al que se publican mensajes.
- **Subscription (suscripción)**: un endpoint (email, SMS, HTTP, Lambda, SQS, etc.) que recibe los mensajes publicados a un tema.
- Las suscripciones por **email** requieren **confirmación manual**: SNS envía un correo con un link; hasta que no se hace clic, la suscripción queda en estado `PendingConfirmation` y no recibe notificaciones.

## Amazon CloudWatch Alarms

Una alarma monitorea una métrica y cambia de estado (`OK` / `ALARM` / `INSUFFICIENT_DATA`) según se cumpla o no una condición. Componentes clave:

| Parámetro | Rol |
|---|---|
| `--namespace` / `--metric-name` | Qué métrica observar (`AWS/Billing` / `EstimatedCharges`) |
| `--statistic` | Cómo agregar los datapoints del período (`Maximum`, `Average`, `Sum`, etc.) |
| `--period` | Tamaño de la ventana de agregación en segundos (ej. `21600` = 6 horas — la granularidad típica de la métrica de billing) |
| `--evaluation-periods` | Cuántos períodos consecutivos deben cumplir la condición para disparar la alarma |
| `--threshold` + `--comparison-operator` | La condición en sí (ej. `GreaterThanThreshold` 10 → se dispara si el gasto supera $10) |
| `--alarm-actions` | Qué hacer al pasar a estado `ALARM` (normalmente, publicar en un tema SNS) |

Al crear una alarma nueva, su estado inicial suele ser `INSUFFICIENT_DATA` — no significa error, solo que aún no hay suficientes datapoints históricos de la métrica para evaluar la condición (la métrica de billing se actualiza pocas veces al día).

## Flujo conceptual completo

```
Cuenta AWS → gasto acumulado → métrica CloudWatch (AWS/Billing, EstimatedCharges, solo en us-east-1)
                                        │
                                        ▼
                        Alarma CloudWatch (umbral de gasto)
                                        │  (al pasar a ALARM)
                                        ▼
                              Publica mensaje en un SNS Topic
                                        │
                                        ▼
                         Suscripción email (confirmada) → notificación al usuario
```
