# Práctica — Setting Up Architecture with Load Balancers

## Enunciado de la tarea

> Configure the load balancer setup for a multi-tier application architecture (ALB internet-facing + NLB interno).

**Región:** `eu-west-1` — Cuenta `536697226993` — VPC `vpc-0a7427875ed6afab6`

**Recursos de la tarea:**
- Web servers: `i-046b2df816149a6b2` (`/customers`, HTTP 8080), `i-0f5833b3fede0b772` (`/orders`, HTTP 8080)
- Backend services: `i-0e5636b9ebd33b4cb` (TCP 3000), `i-07d90a760542b63db` (UDP 7788)
- ALB: `.../loadbalancer/app/cmtr-iacp1ebx-ec2-es-lb/a748221e7849dd94` (internet-facing)
- NLB: `.../loadbalancer/net/cmtr-iacp1ebx-ec2-es-nlb/7210fdc84b3cd3c8` (interno)
- Target Groups ALB: `tg-cust`, `tg-orders` — Target Groups NLB: `tg-tcp`, `tg-udp`

**Objetivos (3 grandes pasos):**
1. Adjuntar cada instancia al Target Group que corresponde.
2. Crear 2 listeners nuevos en el NLB (TCP:3000, UDP:7788).
3. Configurar el listener existente del ALB (puerto 80): rutas `/customers` y `/orders`, y redirect 302 en cualquier otro path hacia `/orders`.

**Nota:** este lab lo resolví directamente en la plataforma (con una combinación de CLI y consola, de ahí que el bono de CLI del Check saliera parcial — 0.667 en vez de 1.0). Documento el flujo de comandos de referencia y, en `03-resultados`, los datos reales confirmados.

---

## Paso 1 — Registrar instancias en sus Target Groups

```bash
TG_CUST_ARN="arn:aws:elasticloadbalancing:eu-west-1:536697226993:targetgroup/cmtr-iacp1ebx-ec2-es-tg-cust/8db1aee349acc7ab"
TG_ORDERS_ARN="arn:aws:elasticloadbalancing:eu-west-1:536697226993:targetgroup/cmtr-iacp1ebx-ec2-es-tg-orders/752402987e21cec9"
TG_TCP_ARN="arn:aws:elasticloadbalancing:eu-west-1:536697226993:targetgroup/cmtr-iacp1ebx-ec2-es-tg-tcp/81e3f507f46f9ae1"
TG_UDP_ARN="arn:aws:elasticloadbalancing:eu-west-1:536697226993:targetgroup/cmtr-iacp1ebx-ec2-es-tg-udp/c45a38472d93c368"

aws elbv2 register-targets --target-group-arn $TG_CUST_ARN   --targets Id=i-046b2df816149a6b2,Port=8080 --region eu-west-1
aws elbv2 register-targets --target-group-arn $TG_ORDERS_ARN --targets Id=i-0f5833b3fede0b772,Port=8080 --region eu-west-1
aws elbv2 register-targets --target-group-arn $TG_TCP_ARN    --targets Id=i-0e5636b9ebd33b4cb,Port=3000 --region eu-west-1
aws elbv2 register-targets --target-group-arn $TG_UDP_ARN    --targets Id=i-07d90a760542b63db,Port=7788 --region eu-west-1
```

## Paso 2 — Listeners del NLB (TCP y UDP)

```bash
NLB_ARN="arn:aws:elasticloadbalancing:eu-west-1:536697226993:loadbalancer/net/cmtr-iacp1ebx-ec2-es-nlb/7210fdc84b3cd3c8"

aws elbv2 create-listener \
  --load-balancer-arn $NLB_ARN \
  --protocol TCP --port 3000 \
  --default-actions Type=forward,TargetGroupArn=$TG_TCP_ARN \
  --region eu-west-1

aws elbv2 create-listener \
  --load-balancer-arn $NLB_ARN \
  --protocol UDP --port 7788 \
  --default-actions Type=forward,TargetGroupArn=$TG_UDP_ARN \
  --region eu-west-1
```

## Paso 3 — Listener del ALB: default action (redirect) + reglas de path

```bash
ALB_ARN="arn:aws:elasticloadbalancing:eu-west-1:536697226993:loadbalancer/app/cmtr-iacp1ebx-ec2-es-lb/a748221e7849dd94"

LISTENER_ARN=$(aws elbv2 describe-listeners \
  --load-balancer-arn $ALB_ARN --region eu-west-1 \
  --query 'Listeners[?Port==`80`].ListenerArn' --output text)

# Default action: redirect 302 hacia /orders para cualquier path no reconocido
aws elbv2 modify-listener \
  --listener-arn $LISTENER_ARN \
  --default-actions '[{"Type":"redirect","RedirectConfig":{"Protocol":"HTTP","Port":"80","Host":"#{host}","Path":"/orders","Query":"#{query}","StatusCode":"HTTP_302"}}]' \
  --region eu-west-1

# Regla: /customers* -> tg-cust
aws elbv2 create-rule \
  --listener-arn $LISTENER_ARN \
  --priority 10 \
  --conditions Field=path-pattern,Values='/customers*' \
  --actions Type=forward,TargetGroupArn=$TG_CUST_ARN \
  --region eu-west-1

# Regla: /orders* -> tg-orders
aws elbv2 create-rule \
  --listener-arn $LISTENER_ARN \
  --priority 20 \
  --conditions Field=path-pattern,Values='/orders*' \
  --actions Type=forward,TargetGroupArn=$TG_ORDERS_ARN \
  --region eu-west-1
```

## Verificación

```bash
curl http://cmtr-iacp1ebx-ec2-es-lb-1706823326.eu-west-1.elb.amazonaws.com/customers
curl http://cmtr-iacp1ebx-ec2-es-lb-1706823326.eu-west-1.elb.amazonaws.com/orders
curl -L http://cmtr-iacp1ebx-ec2-es-lb-1706823326.eu-west-1.elb.amazonaws.com/
```
(`-L` para seguir la redirección 302 en la ruta raíz)
