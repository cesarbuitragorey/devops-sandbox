# Resultados — Setting Up Architecture with Load Balancers

**Estado:** ✅ Tarea completada — **93/100 puntos** (5/5 checks funcionales aprobados, bono de CLI parcial)

## Resumen de los recursos configurados

| Recurso | Configuración |
|---|---|
| Target Group `tg-cust` | `i-046b2df816149a6b2:8080` registrada |
| Target Group `tg-orders` | `i-0f5833b3fede0b772:8080` registrada |
| Target Group `tg-tcp` (NLB) | `i-0e5636b9ebd33b4cb:3000` registrada |
| Target Group `tg-udp` (NLB) | `i-07d90a760542b63db:7788` registrada |
| NLB | 2 listeners nuevos: TCP:3000 → `tg-tcp`, UDP:7788 → `tg-udp` |
| ALB (listener :80) | Default action: redirect 302 a `/orders`; reglas `/customers*` → `tg-cust`, `/orders*` → `tg-orders` |

## Verificación automática de la plataforma

1. **Regla de `/orders` creada correctamente** ✅
2. **`/orders` accesible a través de ambos load balancers** ✅ — `Hello world from Orders service.`
3. **Regla de `/customers` creada correctamente** ✅
4. **`/customers` accesible a través de ambos load balancers** ✅ — `Hello world from Customers service.`
5. **Ruta por defecto (`/`) redirige a Orders** ✅ — `Hello world from Orders service.`
6. **Bono por uso de CLI** ⚠️ — coeficiente **0.667** (esperado 1.0)

## Nota sobre el bono de CLI parcial

Los 5 checks funcionales (rutas, redirects, contenido servido) pasaron al 100%, pero el bono de "CLI usage" salió parcial (0.667 en vez de 1.0) — indica que parte de esta configuración se hizo desde la Consola web en vez de por CLI en esta ejecución particular. No afecta la corrección de la arquitectura, solo resta puntos del bono adicional. Los comandos de `02-practica` documentan el camino 100% CLI equivalente para la próxima vez.

## Recursos destruidos

Al finalizar se usó el botón **"Destroy Resources"** de la plataforma.
