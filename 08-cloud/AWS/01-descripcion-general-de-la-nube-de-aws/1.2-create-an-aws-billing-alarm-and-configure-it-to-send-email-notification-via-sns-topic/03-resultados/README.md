# Resultados — Alarma de facturación con SNS

**Estado:** ✅ Tarea completada y verificada por la plataforma (6/6 checks aprobados)

## Resumen de los recursos creados

| Campo | Valor |
|---|---|
| Tema SNS | `arn:aws:sns:us-east-1:864981748461:cmtr-iacp1ebx-topic` |
| Suscripción | `cesar.buitrago.rey@gmail.com` — protocolo `email`, confirmada |
| Alarma CloudWatch | `cmtr-iacp1ebx-alarm` |
| Namespace / métrica | `AWS/Billing` / `EstimatedCharges` |
| Umbral | Gasto > $10 USD (`GreaterThanThreshold`) |
| Acción de la alarma | Publica en el tema SNS de arriba |

## Verificación automática de la plataforma

1. **Tema SNS existe** ✅ — `cmtr-iacp1ebx-topic`
2. **Protocolo de suscripción = email** ✅
3. **Suscripción confirmada y asociada al tema** ✅
   ```json
   {"Endpoint": "cesar.buitrago.rey@gmail.com", "Protocol": "email", "SubscriptionArn": "arn:aws:sns:us-east-1:864981748461:cmtr-iacp1ebx-topic:0c20e7db-0c3b-4554-8a89-65e0c2b449fb", "TopicArn": "arn:aws:sns:us-east-1:864981748461:cmtr-iacp1ebx-topic"}
   ```
4. **Alarma de CloudWatch existe** ✅ — `cmtr-iacp1ebx-alarm`
5. **Acción de la alarma apunta al tema SNS correcto** ✅
6. **Tipo/namespace de la alarma correcto** ✅ — `AWS/Billing`

## Recursos destruidos

Al finalizar se usó el botón **"Eliminar recursos"** de la plataforma — el tema SNS, la suscripción y la alarma ya no existen fuera de este registro.
