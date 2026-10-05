# Teoría — Task 1.13: AWS IaC with Terraform: Implement Blue-Green Deployment with Traffic Routing

## Blue-green: dos entornos completos y un selector de tráfico

La idea del despliegue blue-green es mantener **dos copias completas** del entorno (aquí: un launch template, un ASG y un target group por color) y decidir con un único punto de control cuánto tráfico recibe cada una. Para actualizar, se despliega la versión nueva en el color inactivo, se prueba ahí sin afectar a los usuarios, y se mueve el tráfico; si algo falla, volver atrás es cambiar los pesos de vuelta, sin redesplegar nada. El "selector" en este lab es el listener del ALB.

## Weighted routing con `forward` y varios `target_group`

El listener HTTP:80 usa una acción `forward` con **dos bloques `target_group`**, cada uno con su `weight`. El ALB reparte las peticiones nuevas en proporción a esos pesos: 100/0 manda todo a Blue, 50/50 a mitades, 0/100 todo a Green. Los pesos son variables (`blue_weight`, `green_weight`) y no valores fijos en el recurso, de modo que cambiar el reparto es cambiar un valor y hacer `apply`, sin tocar la estructura. Es una modificación *in-place* del listener (se vio en el plan: `1 to change`): no se recrea ni el ALB ni ningún entorno.

## Un peso de 0 mantiene el entorno vivo pero sin tráfico real

Con `green_weight = 0` el entorno Green existe, tiene instancias sanas y registradas en su target group, pero no recibe peticiones de usuarios. Eso es justo lo que permite "probarlo con seguridad" antes de promoverlo (el enunciado: Green "can be tested safely"). El coste es que mientras tanto se pagan los dos entornos completos.

## El cambio de pesos no es instantáneo en el ALB

Al probar el 50/50, el primer intento devolvió 10 respuestas `Blue` seguidas — con un reparto real del 50% eso ocurre por azar una de cada ~1000 veces. La causa fue de tiempos: Terraform reporta la modificación del listener como completa en segundos, pero el ALB tarda un poco más en propagar la nueva configuración a sus nodos. Tras esperar 45 s (con ambos targets en `healthy`), 20 peticiones dieron exactamente 10/10. Es una lección práctica para cualquier cutover real: "apply terminado" no equivale a "tráfico ya movido"; conviene esperar y medir antes de dar el cambio por hecho (y, en producción, vigilar métricas mientras se desplaza el tráfico gradualmente, como sugiere el propio enunciado).

## Variables sobreescribibles por línea de comandos

`terraform apply -var="blue_weight=50" -var="green_weight=50"` pisa los valores de `terraform.tfvars` solo para esa ejecución; es cómo se probó el reparto sin editar archivos, y también lo que hace la plataforma para su check de Green. Al ejecutar después un `apply` sin `-var`, Terraform vuelve a los valores del repo (100/0) y el `plan` siguiente da *No changes*: el estado "oficial" del código no cambió en ningún momento.

## Cada ASG se asocia a su propio target group

Hay una correspondencia 1 a 1 que importa: el ASG azul registra sus instancias en el target group azul (`target_group_arns`), y el verde en el verde. Si se cruzaran, el listener mandaría "tráfico Blue" a instancias que sirven la página verde. En el listener se referencian los mismos target groups, de modo que *el peso de un target group es el peso de todas las instancias de su ASG*.

## Datos pre-existentes por data sources, nombres por variables

Igual que en las tasks 1.8 y 1.9: VPC, subnets, security groups y AMI se descubren con data sources (no se hardcodea ningún ID), y los nombres de recursos, la ruta/patrón del AMI y hasta el texto de las páginas (`Blue Environment` / `Green Environment`) se definen como variables con su valor en `terraform.tfvars`, para pasar el check de "hardcoded" sin sorpresas (lección de la task 1.7).
