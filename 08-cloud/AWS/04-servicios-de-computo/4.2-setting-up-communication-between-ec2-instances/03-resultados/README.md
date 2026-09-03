# Resultados — Setting Up Communication between EC2 Instances

**Estado:** ✅ Tarea completada y verificada por la plataforma (7/7 checks aprobados)

## Resumen de los recursos configurados

| Security Group | Reglas agregadas |
|---|---|
| `cmtr-iacp1ebx-ec2-sg-sg-private1_sg` | Allow TCP/80 + Allow ICMP, ambas con `Source` = `cmtr-iacp1ebx-ec2-sg-sg-public1_sg` |
| `cmtr-iacp1ebx-ec2-sg-sg-public1_sg` | Allow TCP/80 + Allow ICMP, ambas con `Source` = `cmtr-iacp1ebx-ec2-sg-sg-private1_sg` |

## Verificación automática de la plataforma

1. **SG privado con exactamente 2 reglas** ✅
2. **SG privado: solo TCP/80 e ICMP, con el SG público como único origen** ✅
3. **SG público con exactamente 2 reglas** ✅
4. **SG público: solo TCP/80 e ICMP, con el SG privado como único origen** ✅
5. **Ping y curl exitosos desde la instancia privada hacia la pública (`10.0.101.156`)** ✅ — `0% packet loss`, respuesta de nginx recibida
6. **Ping y curl exitosos desde la instancia pública hacia la privada (`10.0.1.82`)** ✅ — mismo resultado, confirmando bidireccionalidad completa
7. **Bono por uso de CLI** ✅ — coeficiente 1.0

Los checks 1 y 3 (exactamente 2 reglas por SG, ni una más) confirman que la solución fue exacta — sin reglas de sobra ni permisos más amplios de lo pedido.

## Recursos destruidos

Al finalizar se usó el botón **"Destroy Resources"** de la plataforma.
