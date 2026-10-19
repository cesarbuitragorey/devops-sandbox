# Teoría — Task 1.14: AWS IaC with Terraform: Modules

## Un módulo es una carpeta con entradas, recursos y salidas

Un módulo de Terraform es simplemente un directorio con archivos `.tf` que se invoca desde otra configuración con un bloque `module { source = "./modules/xxx" }`. Su contrato son tres piezas: las **variables** (lo que recibe), los **recursos** (lo que hace) y los **outputs** (lo que devuelve). Por eso el enunciado exige exactamente `main.tf`, `variables.tf` y `outputs.tf` en cada módulo. La configuración que invoca los módulos se llama *root module*.

## Los módulos no se hablan entre sí: se comunican a través de la raíz

`network` no sabe que existe `network_security`. Cada módulo exporta valores con `output` y es la raíz la que los conecta: `module.network.vpc_id` se pasa como `vpc_id` de `network_security`, y `module.network_security.private_http_sg_id` se pasa como entrada de `application`. Terraform deduce el orden de creación a partir de esas referencias (la VPC antes que los SGs, los SGs antes que el launch template), sin necesidad de `depends_on`. La regla del enunciado "no dejes recursos solo en la raíz" busca justamente que la raíz sea un simple cableado.

## Parametrizar sin `default`: todo entra por variables

Un módulo reutilizable no debe contener valores propios del entorno. Aquí cada nombre, CIDR, zona, tipo de instancia, patrón de AMI y tamaño de ASG es una variable del módulo, y los valores reales viven en un único `terraform.tfvars` de la raíz. Los módulos tampoco tienen bloque `provider`: heredan el de la raíz.

## El checker revisa qué tipos de recurso crea cada módulo

Dos de los checks nuevos de esta task validan, módulo por módulo, que el plan solo cree tipos de recurso permitidos. El primer intento falló porque `network_security` usaba `aws_security_group_rule` (reglas como recursos separados); se resolvió declarando las reglas **inline** dentro de `aws_security_group`. Moraleja: las dos formas son equivalentes para AWS, pero en un lab con checker conviene ceñirse a los tipos de recurso más básicos de cada módulo, y mantener las reglas inline hace que el módulo sea más autocontenido (un recurso = un grupo con sus reglas).

## Terraform quita el egress "allow all" por defecto

Al crear un security group, AWS añade una regla de salida que permite todo; el provider de Terraform **la elimina** y exige declararla. Con SGs creados por nosotros (a diferencia de los labs donde ya venían creados) hay que escribir un `egress` explícito, o las instancias no pueden salir a internet para instalar paquetes, y el ALB no puede abrir conexiones hacia ellas. Es un fallo silencioso: el `plan` y el `apply` salen limpios, y el síntoma aparece después como instancias sin servidor web.

## Un identificador "por instancia" que el checker pueda distinguir

El check de balanceo no mide tráfico: compara un **UUID de máquina** extraído de cada respuesta. Si todas las respuestas traen el mismo UUID (o ninguno), concluye que no hay balanceo. Por eso importaba que la página incluyera el UUID de `/sys/devices/virtual/dmi/id/product_uuid` y no solo el instance ID. Lección práctica: los bloques de código del enunciado contenían justo ese dato crítico y no llegaron al copiarlo; cuando un check falla de forma que "no tiene sentido", conviene volver al enunciado original y confirmar que no falta contenido.

## Cambiar el launch template no reemplaza las instancias en marcha

Un ASG con `version = "$Latest"` usa la última versión del launch template solo para las instancias que **lance a partir de ahora**; las que ya corren no se tocan. Tras actualizar el `user_data`, la plataforma (que había aplicado el código encima del despliegue previo) siguió viendo las instancias viejas. Para forzar el reemplazo hay tres caminos: destruir y recrear el ASG, terminar las instancias a mano para que el ASG las relance (lo que se hizo), o declarar un bloque `instance_refresh` en el ASG para que Terraform dispare un reemplazo gradual al cambiar el template. Es la misma idea de "inmutabilidad": cambiar la plantilla no cambia lo ya desplegado.

## Un check fallido deja la infraestructura desplegada

Cuando una verificación falla *después* del `apply`, la plataforma deja los recursos en la cuenta. Eso tiene dos efectos: tu propio `apply` posterior choca con los nombres ya tomados (`already exists`), y la siguiente verificación puede aplicar sobre ese despliegue en lugar de empezar de cero. Consultar el estado real con comandos de solo lectura (`describe-load-balancers`, `describe-target-health`) fue lo que permitió ver qué estaba evaluando el checker.
