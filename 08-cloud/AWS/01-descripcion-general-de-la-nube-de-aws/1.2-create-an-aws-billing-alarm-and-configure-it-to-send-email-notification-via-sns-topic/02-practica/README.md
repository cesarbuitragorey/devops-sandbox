# Práctica — Alarma de facturación de AWS con notificación por SNS

## Enunciado de la tarea

> Crear una alarma de facturación de CloudWatch que envíe notificaciones de facturación a través de un tema de SNS.

**Región obligatoria:** `us-east-1` (las operaciones de facturación están vinculadas a esa región).

**Recursos de la tarea:**
- Tema SNS `${sns_topic}` → en mi ejecución: `cmtr-iacp1ebx-topic`
- Alarma CloudWatch `${alarm_name}` → en mi ejecución: `cmtr-iacp1ebx-alarm`

**Objetivos:**
1. Crear el tema SNS.
2. Crear una suscripción por email al tema.
3. Habilitar alertas de facturación (ya viene hecho en el entorno de pruebas).
4. Crear la alarma de CloudWatch que monitorea `EstimatedCharges`.

**Entorno real usado:** sandbox AWS con credenciales STS temporales, cuenta `864981748461`. Abajo documento ambos caminos (CLI y Consola web) para cada movimiento — en la práctica lo hice todo por CLI local.

---

## Movimiento 1 — Crear el tema SNS

### Opción A — CLI / CloudShell
```bash
aws sns create-topic --name cmtr-iacp1ebx-topic --region us-east-1
```
```json
{
    "TopicArn": "arn:aws:sns:us-east-1:864981748461:cmtr-iacp1ebx-topic"
}
```

### Opción B — Consola web
1. Barra de búsqueda superior → **SNS** → entra al servicio. **Importante**: verifica arriba a la derecha que la región seleccionada sea **US East (N. Virginia) / us-east-1** antes de crear nada.
2. Menú izquierdo → **Topics** → **Create topic**.
3. Type: **Standard**.
4. Name: `cmtr-iacp1ebx-topic`.
5. Deja el resto por defecto → **Create topic**.

**Este movimiento lo hice por CLI.**

---

## Movimiento 2 — Crear la suscripción por email

### Opción A — CLI / CloudShell
```bash
aws sns subscribe \
  --topic-arn arn:aws:sns:us-east-1:864981748461:cmtr-iacp1ebx-topic \
  --protocol email \
  --notification-endpoint cesar.buitrago.rey@gmail.com \
  --region us-east-1
```

### Opción B — Consola web
1. Dentro del tema `cmtr-iacp1ebx-topic` → pestaña **Subscriptions** → **Create subscription**.
2. Protocol: **Email**.
3. Endpoint: la dirección de correo (ej. `cesar.buitrago.rey@gmail.com`).
4. **Create subscription**.

**En ambos casos**, después hay que **confirmar la suscripción**: llega un correo "AWS Notifications - Subscription Confirmation" con un botón/link **Confirm subscription** — sin ese clic, la suscripción queda en `PendingConfirmation` y nunca notifica.

**Este movimiento lo hice por CLI.**

### Incidente: suscripción duplicada con placeholder sin reemplazar

Antes de tener el email definitivo corrí una primera versión del comando con el placeholder `TU_EMAIL@dominio.com` sin reemplazar, lo que dejó una segunda suscripción "fantasma" en estado `PendingConfirmation` (nunca se puede confirmar porque no es un correo real):

```json
{
    "Endpoint": "TU_EMAIL@dominio.com",
    "Protocol": "email",
    "SubscriptionArn": "PendingConfirmation",
    "TopicArn": "arn:aws:sns:us-east-1:864981748461:cmtr-iacp1ebx-topic"
}
```

**Lección**: al copiar comandos con placeholders (`TU_EMAIL@...`, `NOMBRE_USUARIO`, etc.) verificar siempre que se reemplazaron *todos* antes de ejecutar — SNS no valida que el endpoint sea un correo real al momento del `subscribe`, así que el error solo se nota después. No afecta la verificación de la tarea (no cuenta como "existe suscripción confirmada"), y las suscripciones sin confirmar en SNS expiran solas a los 3 días si nadie las confirma.

---

## Movimiento 3 — Habilitar alertas de facturación

Ya venían habilitadas en el entorno de pruebas — sin acción requerida. Si hubiera que hacerlo desde cero:

### Opción A — CLI
No existe una API pública dedicada para esto (`aws cloudwatch enable-billing-alerts` no existe); es un ajuste exclusivo de la Consola.

### Opción B — Consola web
1. Entra a **Billing and Cost Management** (desde el menú del nombre de la cuenta, arriba a la derecha).
2. Menú izquierdo → **Billing Preferences**.
3. Marca **"Receive Billing Alerts"**.
4. **Save preferences**.

---

## Movimiento 4 — Crear la alarma de CloudWatch

### Opción A — CLI / CloudShell
```bash
aws cloudwatch put-metric-alarm \
  --alarm-name cmtr-iacp1ebx-alarm \
  --alarm-description "Billing alarm for account spend" \
  --namespace "AWS/Billing" \
  --metric-name EstimatedCharges \
  --dimensions Name=Currency,Value=USD \
  --statistic Maximum \
  --period 21600 \
  --evaluation-periods 1 \
  --threshold 10 \
  --comparison-operator GreaterThanThreshold \
  --alarm-actions arn:aws:sns:us-east-1:864981748461:cmtr-iacp1ebx-topic \
  --region us-east-1
```
Sin salida = éxito (comportamiento normal de `put-metric-alarm`).

### Opción B — Consola web
1. **CloudWatch** (región `us-east-1`) → menú izquierdo → **Alarms** → **All alarms** → **Create alarm**.
2. **Select metric** → pestaña **Billing** → **Total Estimated Charge** → marca `USD` → **Select metric**.
3. Statistic: **Maximum**, Period: **6 hours** (equivalente a 21600 segundos).
4. Condition: **Static** → **Greater** → Threshold: `10`.
5. **Next** → en "Notification": selecciona el tema SNS existente `cmtr-iacp1ebx-topic` (o créalo desde aquí mismo si no existiera aún).
6. **Next** → Alarm name: `cmtr-iacp1ebx-alarm` → **Next** → **Create alarm**.

**Este movimiento lo hice por CLI.** Verificación:
```bash
aws cloudwatch describe-alarms --alarm-names cmtr-iacp1ebx-alarm --region us-east-1
```
```json
{
    "MetricAlarms": [
        {
            "AlarmName": "cmtr-iacp1ebx-alarm",
            "AlarmArn": "arn:aws:cloudwatch:us-east-1:864981748461:alarm:cmtr-iacp1ebx-alarm",
            "Namespace": "AWS/Billing",
            "MetricName": "EstimatedCharges",
            "Statistic": "Maximum",
            "Dimensions": [{"Name": "Currency", "Value": "USD"}],
            "Period": 21600,
            "EvaluationPeriods": 1,
            "Threshold": 10,
            "ComparisonOperator": "GreaterThanThreshold",
            "AlarmActions": ["arn:aws:sns:us-east-1:864981748461:cmtr-iacp1ebx-topic"],
            "ActionsEnabled": true,
            "StateValue": "INSUFFICIENT_DATA",
            "StateReason": "Unchecked: Initial alarm creation"
        }
    ]
}
```

`StateValue: INSUFFICIENT_DATA` al momento de la creación es normal — la métrica de billing tarda horas en poblar datapoints.
