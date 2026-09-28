# Teoría — Task 1.5: AWS IaC with Terraform: Configure Network Security

## `aws_network_interface_sg_attachment` para no pisar el security group de testing de la plataforma

Las instancias pre-creadas ya traían adjunto un security group propio de la plataforma (usado para sus propios chequeos automatizados). Si se hubiera fijado `vpc_security_group_ids` directamente en un `aws_instance` (o si se hubiera intentado gestionar la instancia entera con Terraform), esa lista habría **reemplazado por completo** los SGs existentes en la interfaz, incluyendo el de testing — justo lo que el enunciado prohíbe explícitamente ("Do not remove or modify the platform security group"). `aws_network_interface_sg_attachment` resuelve esto porque es *aditivo*: adjunta un SG más a una ENI ya existente sin tocar los que ya estaban ahí. Es la diferencia entre "declarar el estado final completo de una lista" (reemplaza) y "agregar un elemento a una colección que ya existe" (aditivo) — dos formas muy distintas de gestionar el mismo tipo de recurso en Terraform, y hay que elegir la que corresponda según si se conoce o no el estado completo deseado.

## `source_security_group_id` vs. `cidr_blocks`: acoplar la regla a una identidad, no a una dirección

La regla del SG privado (`private_http_ingress`) no usa un CIDR fijo — usa `source_security_group_id = aws_security_group.public_http.id`. Esto significa que el tráfico permitido no depende de qué IP tenga la instancia pública en un momento dado (que podría cambiar si se recrea la instancia o si se le asigna una IP elástica distinta), sino de *qué* recurso lo origina: cualquier instancia que tenga adjunto el SG público puede alcanzar la privada, sin importar su IP real. Es el mecanismo estándar en AWS para expresar "solo mi capa pública puede hablarle a mi capa privada" sin necesitar conocer ni mantener direcciones IP internas.

## `aws_security_group_rule` como recursos independientes vs. bloques `ingress` inline

Igual que con S3 (lab 1.3), aquí se optó por reglas como recursos separados en vez de bloques `ingress {}` dentro del propio `aws_security_group`. La ventaja concreta en este lab: cada regla (SSH, ICMP, HTTP) es su propio recurso con su propio ciclo de vida en el state — se puede agregar, quitar o modificar una regla individual sin que Terraform recalcule ni reemplace el bloque completo de `ingress` del grupo, lo cual habría sido más frágil dado que un mismo SG (`ssh`) recibe reglas para dos protocolos distintos (TCP y ICMP) que conceptualmente son independientes entre sí.

## ICMP "todos los tipos" se expresa con `from_port`/`to_port` en `-1`

A diferencia de TCP/UDP donde `from_port`/`to_port` acotan un rango de puertos, en una regla ICMP esos mismos campos se interpretan como *type* y *code* de ICMP. El valor `-1` en ambos es la convención de AWS para "cualquier type, cualquier code" — es decir, permitir el protocolo ICMP completo (ping y todos los demás mensajes de control), no un puerto "-1" literal.
