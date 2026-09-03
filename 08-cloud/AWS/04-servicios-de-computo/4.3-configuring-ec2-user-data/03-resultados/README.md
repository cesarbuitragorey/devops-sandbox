# Resultados — Configuring EC2 User Data

**Estado:** ✅ Tarea completada y verificada por la plataforma (4/4 checks aprobados)

## Resumen de los recursos configurados

| Recurso | Valor |
|---|---|
| Launch Template | `cmtr-iacp1ebx-ec2-us-lt`, nueva versión marcada como `$Default` |
| Auto Scaling Group | `cmtr-iacp1ebx-ec2-us-asg` — sin cambios en su configuración, solo se le hizo instance refresh |
| Instancia resultante | `i-0034ebdfc286a6447`, IP pública `54.77.113.174` |

## Verificación automática de la plataforma

1. **El ASG usa la versión `$Default` del launch template** ✅
2. **El servidor responde `200 OK`** ✅
3. **El contenido de la página muestra el IP y el Instance ID correctos** ✅ — `WebServer (54.77.113.174) with ID: i-0034ebdfc286a6447`
4. **Bono por uso de CLI** ✅ — coeficiente 1.0

## Recursos destruidos

Al finalizar se usó el botón **"Destroy Resources"** de la plataforma.
