# Teoría — Task 1.6: AWS IaC with Terraform: Form TF Output

## La misma infraestructura, un contrato de outputs distinto

Esta task despliega exactamente la misma red que la task 1.1 (VPC + 3 subnets públicos + IGW + route table, mismos nombres y CIDRs), pero el foco de la evaluación es otro: no es "¿se creó la infraestructura correctamente?" sino "¿el archivo `outputs.tf` expone los valores correctos con los nombres exactos que pide el consumidor de ese output?". Esto refleja un caso real: cuando otra configuración de Terraform (u otro equipo) va a consumir estos outputs vía `terraform_remote_state`, el *nombre* de cada output es parte del contrato — cambiarlo (aunque el valor sea idéntico) rompe a quien lo consume. Aquí el output final se llama `routing_table_id`, no `route_table_id` como en la 1.1: un cambio de nombre trivial, pero que un checker automatizado (o un colega) puede fallar en detectar si no se lee el enunciado con cuidado.

## Outputs de tipo map vs. outputs escalares

Como hay 3 subnets creados con `for_each`, los outputs `public_subnet_ids`, `public_subnet_cidr_block` y `public_subnet_availability_zone` no pueden ser un solo string — se expresan como `map` (`{ for k, s in aws_subnet.public : k => s.<atributo> }`), indexados por la misma clave (`a`/`b`/`c`) que la variable `public_subnets`. Esto mantiene la correspondencia entre "a qué subnet pertenece cada valor" visible en el output mismo, en vez de depender de que las tres listas separadas (ids, cidrs, azs) mantengan el mismo orden implícitamente — algo frágil si en el futuro se agrega o quita un subnet del mapa.

## Reutilizar diseño ya probado en vez de reinventar

Al ser la misma arquitectura de red que un lab anterior, no hubo necesidad de tomar nuevas decisiones de diseño (`for_each` sobre `map(object(...))`, sin `default` en variables, backend local implícito) — simplemente se adaptó el archivo `outputs.tf` a los nombres pedidos. Esto ahorró tiempo de desarrollo y redujo el riesgo de errores, mostrando el valor de un patrón ya validado por un checker anterior (17/17 en la task 1.1) frente a escribir código nuevo desde cero.
