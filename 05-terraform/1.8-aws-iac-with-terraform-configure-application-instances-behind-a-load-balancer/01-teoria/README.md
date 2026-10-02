# Teoría — Task 1.8: AWS IaC with Terraform: Configure Application Instances behind a Load Balancer

## Launch Template → ASG → Target Group → ALB: quién conecta con quién

La cadena tiene cuatro piezas con responsabilidades distintas. El **Launch Template** define *cómo* se lanza cada instancia (AMI, tipo, SGs, perfil IAM, `user_data`). El **ASG** decide *cuántas* instancias hay y *dónde* (subnets), usando el template. El **Target Group** es la lista de destinos que el balanceador usa, con su health check. El **ALB + listener** es el punto de entrada: el listener del puerto 80 reenvía al target group. Lo que une al ASG con el target group es `aws_autoscaling_attachment` — sin él, las instancias se crean pero el ALB no les manda tráfico.

## `ignore_changes` en `load_balancers` y `target_group_arns`

El enunciado pide ese bloque `lifecycle` en el ASG porque `aws_autoscaling_attachment` modifica esos mismos atributos del ASG por fuera del recurso `aws_autoscaling_group`. Si Terraform no los ignorara, en cada `plan` vería una diferencia entre lo que declara el ASG (sin target groups) y lo que realmente tiene (el attachment los agregó) e intentaría "corregirlo", peleando con el attachment. Es el caso típico de dos recursos que gestionan el mismo atributo: se resuelve diciéndole a uno de ellos que lo ignore.

## IMDSv2 con `http_tokens = "optional"`

El script usa IMDSv2 (primero pide un token con `PUT`, luego lo manda en el header `X-aws-ec2-metadata-token`). Aun así, el enunciado fija `http_tokens = "optional"`, que significa que la instancia acepta *tanto* IMDSv1 como IMDSv2; `required` obligaría a usar solo v2. Usar v2 en el script es la práctica correcta aunque el template no lo exija.

## Escapar `$` dentro del heredoc de Terraform

El `user_data` se escribe como heredoc en HCL, y Terraform interpola `${...}`. Por eso las variables de bash se usan sin llaves (`$TOKEN`, `$INSTANCE_ID`): `$VAR` pasa tal cual al script, mientras que `${VAR}` lo intentaría resolver Terraform y fallaría. La alternativa sería escapar como `$${VAR}`.

## Instancias en subnets públicos con IP pública

Las instancias necesitan salir a internet para ejecutar `dnf update`/`dnf install` en el arranque. Con el entorno pre-creado (subnets públicos y privados, sin NAT mencionado), se lanzaron en los subnets públicos con `associate_public_ip_address = true` dentro de `network_interfaces`. Detalle: al usar el bloque `network_interfaces` los security groups se declaran dentro de él (`security_groups`), no con `vpc_security_group_ids` a nivel del template; ambos no pueden convivir.

## Los strings "hardcodeados" también cuentan en el checker

Por la experiencia de la task 1.7 (el checker marcó la ruta del parámetro SSM como hardcodeada), aquí todos los nombres, CIDRs, la ruta SSM del AMI, el tipo de instancia y las capacidades del ASG se definieron como variables con su valor en `terraform.tfvars`, y la verificación ya no tuvo ese problema.
