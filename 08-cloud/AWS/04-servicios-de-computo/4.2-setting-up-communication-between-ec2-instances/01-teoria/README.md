# Teoría — Comunicación entre instancias EC2 vía Security Group como origen

## Security Group como `Source`, no un CIDR

Una regla de Security Group no está limitada a usar un rango de IPs (`CidrIp`) como origen — también puede usar **otro Security Group** como `Source` (`--source-group` en la CLI). Cuando se hace esto, la regla se cumple para **cualquier instancia que tenga ese Security Group adjunto**, sin importar su IP específica, y sin importar si esa IP cambia (por ejemplo, si la instancia se reemplaza y obtiene una IP nueva). Es el patrón recomendado para comunicación entre grupos de instancias (ej. "todo lo que tenga el SG de app-servers puede llegar al puerto 5432 de lo que tenga el SG de db-servers"), en vez de mantener listas de IPs a mano.

## Por qué hacen falta reglas en *ambos* Security Groups (no solo uno)

Los Security Groups son **stateful** para una misma conexión (la respuesta a una request permitida vuelve automáticamente, sin necesitar una regla de salida específica), pero eso no cubre conexiones **iniciadas** en ambas direcciones. En este lab, cada instancia necesita poder:
1. Iniciar tráfico HTTP/ICMP hacia la otra (`curl`/`ping` de A hacia B).
2. Recibir ese tráfico en el otro extremo.

Como ambas instancias hacen ping/curl la una a la otra (comunicación bidireccional iniciada por ambos lados, no solo una respuesta), cada Security Group necesita sus propias reglas de entrada permitiendo el origen correspondiente — de ahí que sean 2 reglas por SG (uno para TCP/80, otro para ICMP), 4 en total.

## ICMP en reglas de Security Group

A diferencia de TCP/UDP (que usan "puertos"), ICMP (usado por `ping`) se identifica por **tipo y código** de mensaje (ej. tipo 8 = Echo Request, tipo 0 = Echo Reply). Para permitir `ping` en ambas direcciones sin tener que enumerar cada tipo/código posible, se usa la convención de la CLI `--protocol icmp --port -1` (o `IpProtocol: icmp, FromPort: -1, ToPort: -1` en el JSON), que significa "todos los tipos y códigos de ICMP" — cubre tanto el Echo Request como el Echo Reply necesarios para que un `ping` complete su ida y vuelta.

## Diseño de este lab: 4 movimientos = 4 reglas

| # | SG destino | Regla | Source |
|---|---|---|---|
| 1 | Private SG | Allow TCP 80 | Public SG |
| 2 | Private SG | Allow ICMP (todo) | Public SG |
| 3 | Public SG | Allow TCP 80 | Private SG |
| 4 | Public SG | Allow ICMP (todo) | Private SG |

El Security Group de conectividad de Session Manager (`cmtr-iacp1ebx-ec2-sg-sg-session-manager-connectivity`) se deja intacto — no forma parte de la comunicación entre instancias, solo habilita el acceso administrativo vía SSM, y el enunciado advierte explícitamente no tocarlo.
