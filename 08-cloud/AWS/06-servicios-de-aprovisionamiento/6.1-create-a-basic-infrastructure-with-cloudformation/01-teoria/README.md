# Teoría — Infraestructura básica con CloudFormation

## Rol de servicio para CloudFormation vs. permisos del usuario que despliega

`aws cloudformation create-stack` acepta `--role-arn`, un rol que **CloudFormation mismo** asume (vía `sts:AssumeRole` con `Principal.Service: cloudformation.amazonaws.com`) para crear/modificar los recursos del stack — es independiente de los permisos IAM que tenga el usuario o rol que ejecuta el comando `create-stack`. Esto permite que un usuario con permisos limitados pueda desplegar un stack que crea recursos (VPC, EC2, IAM roles, etc.) que ese mismo usuario no podría crear directamente, siempre que el rol de servicio tenga los permisos necesarios.

## `--capabilities CAPABILITY_NAMED_IAM`

Cuando una plantilla crea recursos `AWS::IAM::Role` (o `Policy`/`InstanceProfile`) **con un nombre explícito** (`RoleName: cmtr-iacp1ebx-role`), `create-stack` rechaza la operación a menos que se reconozca explícitamente el riesgo de que el stack maneje identidades con nombre fijo, vía `--capabilities CAPABILITY_NAMED_IAM`. Si el rol no tuviera `RoleName` (dejando que CloudFormation genere el nombre), bastaría con `CAPABILITY_IAM`.

## `AWS::SSM::Parameter::Value<AWS::EC2::Image::Id>`

En vez de fijar un `ImageId` de AMI hardcodeado (que queda obsoleto y varía por región), este tipo de parámetro resuelve en tiempo de despliegue el valor de un parámetro público de SSM Parameter Store — en este caso `/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64`, que siempre apunta al AMI ID más reciente de Amazon Linux 2023 en la región donde se despliega el stack.

## `Fn::Sub` + `Fn::Base64` en `UserData`

El `UserData` de una instancia EC2 debe ir codificado en Base64 (`Fn::Base64`) — es el mecanismo estándar mediante el cual EC2 recibe el script de arranque (`cloud-init`) sin importar el tamaño o caracteres especiales del script. `Fn::Sub` dentro de eso permite interpolar valores de la plantilla (parámetros, referencias a otros recursos) directamente en el string del script — aunque en este lab no hizo falta interpolar nada dinámico dentro del script en sí, ambos scripts (instancia 1 y 2) solo difieren en el texto literal del mensaje.

## Redes públicas: por qué cada subnet necesita su propia asociación a la tabla de rutas

Una tabla de rutas con una ruta `0.0.0.0/0 → Internet Gateway` no hace pública una subnet por sí sola — se necesita además una `AWS::EC2::SubnetRouteTableAssociation` explícita que vincule esa subnet a esa tabla. En este lab se usó una tabla de rutas separada por subnet (`PublicRouteTable1`/`PublicRouteTable2`), aunque también habría sido válido compartir una sola tabla entre ambas subnets públicas — la elección de duplicarla fue por claridad/paralelismo con el resto de la plantilla, no por una restricción técnica.

## `DependsOn` en la ruta hacia el Internet Gateway

La `AWS::EC2::Route` que apunta al Internet Gateway declara `DependsOn: AttachGateway` porque el Internet Gateway debe estar **adjunto** a la VPC (`AWS::EC2::VPCGatewayAttachment`) antes de que la ruta pueda referenciarlo como target — sin esta dependencia explícita, CloudFormation podría intentar crear la ruta en paralelo con el attachment y fallar, ya que no hay una referencia directa (`!Ref`/`!GetAtt`) entre ambos recursos que fuerce el orden automáticamente.
