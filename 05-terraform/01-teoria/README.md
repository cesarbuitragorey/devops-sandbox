# Teoría — Terraform / Infrastructure as Code

## ¿Qué es Infrastructure as Code (IaC) y Terraform?

Infrastructure as Code es una práctica ya estándar al trabajar con proveedores cloud. En pocas palabras, permite a los ingenieros gestionar sus recursos de nube de forma efectiva usando código. Terraform es una de las herramientas de IaC más populares (y no sin razón). Permite declarar la infraestructura usando código simple y legible, que la propia herramienta usa después para aprovisionar todos los recursos descritos en el orden necesario.

Terraform fue creado por HashiCorp, y su misión — declarada por Mitchell Hashimoto, uno de los fundadores de la compañía — es construir y modificar infraestructura de forma segura y eficiente. La herramienta soporta aprovisionar recursos usando múltiples providers, y no se limita a nubes como AWS, GCP o Azure: también soporta trabajar con Kubernetes, Vault, Helm, Consul, VMware vSphere y decenas de [otros providers](https://registry.terraform.io/browse/providers).

En resumen, Terraform es una herramienta de IaC potente, flexible y en constante desarrollo, usada exitosamente por una comunidad de miles de profesionales alrededor del mundo.

## ¿Por qué IaC?

IaC se vende solo. Sus principales ventajas son:

- **Velocidad:** recursos como clusters completos de Kubernetes pueden crearse en cuestión de minutos.
- **Consistencia:** el control de versiones y la validación de código aseguran despliegues fluidos.
- **Escalabilidad:** desde una sola regla de security group hasta clusters EKS gigantes.
- **Costos:** la eficiencia y escalabilidad de IaC permiten optimizar mejor la infraestructura.
- **Seguridad:** las configuraciones seguras se aplican de forma consistente y no pueden modificarse fuera de código bajo el paradigma de infraestructura inmutable.

## ¿Por qué Terraform?

Existen muchas otras herramientas de IaC. ¿Por qué usar Terraform específicamente? Además de la ya mencionada amplia variedad de providers (y por lo tanto la capacidad de gestionar infraestructura multi-cloud con una sola herramienta), también es open source. Herramientas similares como AWS CloudFormation, Azure Resource Manager y Google Cloud Deploy solo funcionan con su correspondiente entorno cloud.

No hay que confundir Terraform con herramientas de gestión de configuración como Ansible, Chef, Puppet o SaltStack. Estas trabajan con infraestructura mutable tradicional que cambia continuamente (por ejemplo, un administrador se conecta por SSH y modifica algo en una instancia EC2 o un security group ya aprovisionados) y son susceptibles al *configuration drift*. Estas herramientas también suelen necesitar un servidor master e instalación de agentes. Terraform está diseñado para trabajar con infraestructura inmutable que (en general) no cambia después de aprovisionada y convenientemente no requiere nada de eso.

Otra característica importante de Terraform es la **idempotencia**. En este contexto significa básicamente que la infraestructura, una vez aprovisionada, no se modificará por volver a correr el mismo comando de aprovisionamiento.

Finalmente, Terraform usa HashiCorp Configuration Language (HCL), diseñado para ser simple de aprender y de leer. HCL es mucho más flexible y conveniente que JSON, YAML o XML.

## Conceptos clave

### Archivos de configuración

Un archivo de configuración de Terraform (o simplemente "configuración") es un documento completo escrito en HCL que le indica a Terraform cómo gestionar una colección de infraestructura determinada. Una configuración puede estar compuesta de múltiples archivos y directorios. Es importante recordar que representa el **estado deseado** de los recursos, no el estado real de los recursos ya aprovisionados.

### Terraform state

El concepto más importante de entender para quien empieza. Se puede pensar en el [Terraform state](https://www.terraform.io/language/state) como una base de datos especial donde la herramienta guarda lo que sabe sobre los recursos ya aprovisionados. El state le permite a Terraform saber cuándo y dónde hacer los cambios descritos en los archivos de configuración. El state de Terraform, los recursos aprovisionados y los archivos de configuración son tres entidades separadas y cruciales de entender — hay que tenerlas siempre presentes, junto con la razón por la que Terraform trabaja con las tres.

¿Qué pasa al usar comandos como `terraform apply` o `terraform destroy`? La herramienta reconcilia el estado deseado (los archivos de configuración con el código) con los recursos reales (en AWS, en nuestro caso) y, si es necesario, hace los cambios correspondientes, modificando el state para que refleje los recursos reales en el momento en que el comando termina exitosamente.

El state de Terraform puede almacenarse de forma local (no recomendado si no se trabaja en solitario, y por razones de seguridad) o en almacenamiento remoto (por ejemplo, en un bucket S3 creado específicamente para eso). Cuando Terraform corre, bloquea (*lock*) el state remoto para que no pueda ser modificado por otros usuarios mientras se aprovisiona la infraestructura; esto previene errores de state que pueden ocurrir cuando dos o más ingenieros modifican los mismos recursos al mismo tiempo.

### init, plan, apply, destroy y refresh

Los cuatro comandos principales de Terraform que se usan con frecuencia:

- `terraform init`, en un directorio con archivos de configuración, descarga todos los módulos necesarios para usarse después y se conecta al Terraform state (configurándolo local o remotamente).
- `terraform plan` permite planear los cambios de infraestructura sin aplicarlos.
- `terraform apply` corre el plan y aprovisiona todo lo descrito en el código, previa confirmación del usuario.
- `terraform destroy` hace lo opuesto: planea la eliminación y luego borra los recursos descritos en el código, previa confirmación del usuario.
- `terraform refresh` lee la configuración actual de todos los recursos gestionados y actualiza el Terraform state para que coincida. No agrega al state ningún recurso nuevo que no esté descrito en la configuración.

### validate y fmt

Dos comandos simples pero muy útiles para asegurar que el código sea válido y esté bien formateado. Conviene usarlos con regularidad — o, mejor aún, automáticamente:

- `terraform validate` valida la consistencia y sintaxis de los archivos de configuración de un directorio, refiriéndose únicamente a la configuración, sin acceder a ningún servicio remoto como el state remoto, las APIs de los providers, etc.
- `terraform fmt` reescribe los archivos de configuración de Terraform según [un formato y estilo canónico](https://www.terraform.io/language/syntax/style).

### Providers

Volviendo a los [providers](https://www.terraform.io/language/providers): son básicamente subcomponentes de Terraform que gestionan la interacción con una plataforma específica, como AWS o Azure. Los providers son desarrollados por HashiCorp, por la comunidad de Terraform, y por terceros que quieren que sus servicios estén fácilmente disponibles para los usuarios de Terraform.

Si se trabaja tanto con AWS como con Azure (o Digital Ocean, GCP, etc.), hay que especificar esos providers y sus versiones en el código. Un provider permite direccionar los recursos específicos de esa plataforma — por ejemplo, el provider de AWS trabaja con recursos como instancias EC2, políticas IAM, security groups y muchos otros; el provider de Kubernetes trabaja con namespaces, deployments, ingresses, configmaps, etc.

Al mismo tiempo, existen providers básicos que permiten a Terraform trabajar con archivos, binarios externos, claves de seguridad o simplemente números aleatorios. Todos estos pueden ser muy útiles al definir infraestructura.

Es importante notar que incluso providers maduros como el de AWS no tienen algunos de los recursos que ofrece su servicio nativo correspondiente — basta con mirar su [changelog](https://github.com/hashicorp/terraform-provider-aws/blob/main/CHANGELOG.md). Así que, aunque Terraform es efectivamente potente, a veces no puede hacerlo todo, ya que depende de que los providers hagan sus recursos direccionables.

### Data sources y outputs

Los [data sources](https://www.terraform.io/language/data-sources) de Terraform abarcan varias consultas que Terraform puede ejecutar para obtener la información necesaria desde fuera del propio Terraform, de otra configuración, o de alguna función. Por ejemplo, una aplicación puede estar aprovisionada usando varios states de Terraform que necesitan compartir algún dato, como un VPC id o un security group id. Si esos ids cambian, correr `terraform apply` proveerá sus nuevos valores en tiempo real.

¿Cómo obtiene un data source algún dato de otro state de Terraform? Ese state necesita tener [outputs](https://www.terraform.io/language/values/outputs) definidos. Estos pueden tener cualquier información útil, como hostnames de RDS, CIDRs o ids de security groups. Los outputs también se usan en los módulos.

### Modules

Los [módulos](https://www.terraform.io/language/modules) de Terraform son básicamente como clases. Permiten reutilizar código en múltiples configuraciones. ¿Se necesita aprovisionar clusters EKS para la Aplicación A y la Aplicación B? Se puede usar [el módulo oficial](https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest). ¿Se necesitan más features o personalizaciones específicas? Se puede modificar, o crear un módulo propio desde cero — aunque esta última opción significa que ahora hay que mantener ese módulo propio, lo cual no es una tarea trivial.

Un módulo normalmente requiere proveer las variables necesarias, como CIDRs de VPC o la versión del cluster de Kubernetes. Luego usa su propia configuración, con providers y recursos predefinidos, para aprovisionar rápidamente la pieza de infraestructura especificada, a la vez que provee outputs útiles.

Los módulos, de nuevo, son [abundantes](https://registry.terraform.io/) y son desarrollados por una enorme comunidad mundial.

### Variables y locals

Las [variables](https://www.terraform.io/language/values/variables) de Terraform se pueden pensar como los argumentos de una función. Permiten personalizar aspectos de los módulos de Terraform sin alterar el código fuente del propio módulo. Esto permite compartir módulos entre distintas configuraciones de Terraform, haciendo que el módulo sea componible y reutilizable. Los outputs mencionados antes son como los valores de retorno de una función.

Los [locals](https://www.terraform.io/language/values/locals) son simplemente valores transformados que usa un módulo o configuración. Se pueden pensar como las variables locales temporales de una función, necesarias para que esta funcione correctamente.

### Functions

HCL, como la mayoría de los lenguajes, provee una biblioteca estándar de [funciones](https://www.terraform.io/language/functions) que se pueden usar para transformar variables y cualquier otro dato que sea necesario pasar entre recursos. ¿Se necesita multiplicar algo o dividir un string? Hay funciones para eso. ¿Se necesita decodificar datos JSON u obtener un hash MD5? También hay funciones para eso. ¿Generar números con un step definido? También está cubierto.

### Workspaces

Cada configuración de Terraform tiene un backend asociado que define cómo se ejecutan las operaciones y dónde se almacenan los datos persistentes, como el Terraform state (localmente, en un bucket S3, en Consul, etc.).

Los datos persistentes almacenados en el backend pertenecen a un [workspace](https://www.terraform.io/language/state/workspaces). Inicialmente el backend tiene un solo workspace, llamado "default", y por lo tanto hay un único Terraform state asociado a esa configuración. Ciertos backends soportan múltiples workspaces con nombre, permitiendo que varios states estén asociados a una sola configuración. La configuración sigue teniendo un único backend, pero permite desplegar múltiples instancias distintas de esa configuración sin tener que configurar un backend nuevo ni cambiar las credenciales de autenticación.

Crear workspaces adicionales es opcional, pero puede ser útil en ciertas situaciones (por ejemplo, si se tienen múltiples clusters EKS en distintas regiones de AWS).

También se pueden usar herramientas adicionales como [Terraspace](https://github.com/boltops-tools/terraspace) o [Terragrunt](https://github.com/gruntwork-io/terragrunt). Estas también son completamente opcionales, pero pueden facilitar el flujo de trabajo si se necesitan las features que ofrecen (y se está dispuesto a invertir tiempo adicional en aprenderlas).

## Video recomendado

- [Terraform in 15 minutes](https://www.youtube.com/watch?v=l5k1ai_GBDE)

## Snippets de código de Terraform

La teoría en crudo no sirve de mucho sin ejemplos prácticos. Todos los ejemplos de código reales se encuentran en el [repositorio del curso](https://git.epam.com/epmc-acm-public/tf-epam-lab/-/tree/main/examples) o en los siguientes enlaces:

- [Terraform Settings](https://git.epam.com/epmc-acm-public/tf-epam-lab/-/blob/main/examples/settings.md#terraform-settings)
- [Provider Configuration](https://git.epam.com/epmc-acm-public/tf-epam-lab/-/blob/main/examples/providers.md#provider-configuration)
- [Resource Blocks](https://git.epam.com/epmc-acm-public/tf-epam-lab/-/blob/main/examples/resources.md#resource-blocks)
- [Data Sources](https://git.epam.com/epmc-acm-public/tf-epam-lab/-/blob/main/examples/data_sources.md#data-sources)
- [Input Variables](https://git.epam.com/epmc-acm-public/tf-epam-lab/-/blob/main/examples/variables.md#input-variables)
- [Locals Variables](https://git.epam.com/epmc-acm-public/tf-epam-lab/-/blob/main/examples/locals.md#local-values)
- [Outputs](https://git.epam.com/epmc-acm-public/tf-epam-lab/-/blob/main/examples/outputs.md#input-variables)
- [Functions](https://git.epam.com/epmc-acm-public/tf-epam-lab/-/blob/main/examples/functions.md#functions)
- [Modules](https://git.epam.com/epmc-acm-public/tf-epam-lab/-/blob/main/examples/modules.md#modules)

## Enlaces útiles

- [Terraform documentation](https://www.terraform.io/docs). Se usa constantemente. Las secciones más importantes para revisar primero:
  - [syntax](https://www.terraform.io/language/syntax/configuration)
  - [style conventions](https://www.terraform.io/language/syntax/style)
  - [conditional expressions](https://www.terraform.io/language/expressions/conditionals)
- [Terraform AWS tutorials](https://learn.hashicorp.com/collections/terraform/aws-get-started). Amigables para principiantes y rápidos. También disponibles para [GCP](https://developer.hashicorp.com/terraform/tutorials/gcp-get-started) y [Azure](https://developer.hashicorp.com/terraform/tutorials/azure-get-started).
- [Un video tutorial de Terraform más largo (2+ horas)](https://www.youtube.com/watch?v=SLB_c_ayRMo). Más completo y detallado.
- Enlaces de mejores prácticas de Terraform:
  - [Una recopilación completa de mejores prácticas por Anton Babenko y la comunidad de Terraform](https://www.terraform-best-practices.com/)
  - [Algunas mejores prácticas e indicaciones útiles adicionales](https://github.com/ozbillwang/terraform-best-practices)
  - [Prácticas de workflow recomendadas por HashiCorp](https://www.terraform.io/cloud-docs/guides/recommended-practices)
- [EPAM Terraform Associate Certification Preparation](https://videoportal.epam.com/playlist/VYjK5oJ0/play/V7goNx70) (5 videos). Un set de charlas para prepararse para el proceso de certificación oficial de Terraform.
- [EPAM Terraform Associate Certification Overview](https://kb.epam.com/download/attachments/1109962808/Terraform%20Associate%20Certification%20Preparation%20by%20Armando%20Herra.pptx?version=1&modificationDate=1622464133944&api=v2). Presentación clara y concisa que se puede usar como punto de partida en el camino hacia la certificación Terraform Associate.

## Check yourself (autoevaluación)

Intenta responder las siguientes preguntas usando el conocimiento adquirido arriba. Imagina que aprovisionaste una configuración con una instancia EC2 en AWS usando `terraform apply`, así que tienes:

- **a)** tus archivos de configuración;
- **b)** un Terraform state local con dicha instancia EC2 ya registrada; y
- **c)** el recurso real ya aprovisionado y funcionando en AWS.

### Preguntas principales

1. ¿Qué le pasa a a), b) y c) después de borrar el recurso (la instancia EC2, por ejemplo) de su archivo de configuración y correr `terraform apply`?
2. ¿Qué pasa después de borrar ese mismo recurso directamente en AWS y correr `terraform apply`?
3. ¿Qué pasa después de borrar ese mismo recurso de tu Terraform state y correr `terraform apply`?
4. ¿Qué pasa después de modificar ese mismo recurso en el archivo de configuración y correr `terraform apply`?
5. ¿Qué pasa después de borrar ese mismo recurso de su archivo de configuración y correr `terraform destroy`?

### Preguntas adicionales

1. ¿Cuál es la diferencia entre un provider y un módulo?
2. ¿Qué pasa si borras tu archivo de Terraform state?
3. ¿Qué pasa si borras un provider de tu directorio local `.terraform` en tu configuración?
4. ¿Qué pasa si borras el directorio `.terraform` completo de tu configuración?

Si estás seguro de haber respondido todas (o la mayoría) correctamente, ¡bien hecho! Estás listo para la parte principal de este módulo.

### Respuestas

1. **Borrar el recurso del archivo de configuración + `apply`:** Terraform compara config (sin el recurso) contra el state (que sí lo tiene) y planea **destruirlo**. Tras confirmar, `apply` borra la instancia real en AWS y elimina la entrada del state. Resultado: a) ya no lo tiene (lo borraste tú), b) el state queda sin esa entrada, c) el recurso deja de existir en AWS.
2. **Borrar el recurso en AWS + `apply`:** durante el `plan` implícito, Terraform refresca el state y detecta que el recurso ya no existe en la realidad (drift). Como la configuración **sigue** declarándolo, Terraform planea **crearlo de nuevo**. `apply` crea una instancia nueva (con un ID distinto a la original). Resultado: a) sin cambios, b) el state termina con una entrada para la instancia nueva, c) existe una instancia EC2 nueva en AWS (la original ya no existía).
3. **Borrar el recurso del state (`terraform state rm`) + `apply`:** el state ya no sabe nada del recurso, pero sigue existiendo en AWS y sigue declarado en la configuración. Terraform ve "falta en el state, está en config" y planea **crearlo** — no lo reconoce como el mismo recurso. `apply` crea una instancia nueva. Resultado: a) sin cambios, b) el state gana una entrada para la instancia nueva, c) ahora hay **dos** instancias EC2 en AWS: la original (huérfana, ya no gestionada por Terraform) y la nueva.
4. **Modificar el recurso en config + `apply`:** flujo normal de actualización. Terraform planea un update in-place o un replace (según si el atributo cambiado fuerza recreación) y lo aplica. Resultado: a) ya modificado por ti, b) el state se actualiza con los nuevos atributos (y un nuevo ID si hubo replace), c) el recurso en AWS queda modificado o reemplazado según corresponda.
5. **Borrar el recurso de config + `terraform destroy`:** `destroy` no filtra por lo que hay en el archivo de configuración — genera un plan para eliminar **todo lo que el state tiene bajo gestión**, exista o no en la configuración actual. Como el recurso sigue en el state (venía de la base del escenario), `destroy` también lo elimina, junto con el resto de los recursos gestionados. Resultado: a) sin cambios (destroy no toca archivos de config), b) el state queda vacío, c) todos los recursos gestionados —incluida esa instancia EC2— se eliminan de AWS.

**Adicionales:**

1. **Provider vs. módulo:** un *provider* es el plugin que traduce HCL a llamadas reales contra la API de una plataforma (AWS, Azure, Kubernetes, etc.) — es lo que provee los tipos de recurso (`aws_instance`, `aws_vpc`...). Un *módulo* es un contenedor reutilizable de configuración (bloques de recursos, variables, outputs) construido **usando** recursos de uno o más providers — empaqueta un patrón de infraestructura para reutilizarlo, pero no habla directamente con ninguna API.
2. **Borrar el archivo de state:** Terraform pierde todo conocimiento de lo que está gestionando. Ni los archivos de configuración ni los recursos reales en AWS se ven afectados de inmediato. Pero el siguiente `plan`/`apply` verá un state "vacío" contra una configuración con recursos declarados, y planeará **crearlos todos de nuevo** — probablemente duplicando recursos que sí lo permiten (varias instancias EC2), o fallando con error de "ya existe" en recursos con restricciones de unicidad global (un bucket S3 con nombre ya tomado). Para recuperarse sin recrear nada, hay que re-importar cada recurso a un state nuevo con `terraform import`.
3. **Borrar un provider de `.terraform`:** `terraform init` descarga los plugins de los providers dentro de `.terraform/providers/`. Si borras manualmente el binario de un provider específico (dejando el resto de `.terraform`, incluido el lock file `.terraform.lock.hcl`, intacto), el siguiente `plan`/`apply` que lo necesite fallará indicando que no encuentra el plugin requerido, y pedirá volver a correr `terraform init` para reinstalarlo.
4. **Borrar el directorio `.terraform` completo:** se pierden los binarios de todos los providers descargados, la caché de módulos locales y la metadata de configuración del backend — pero **no** el archivo de state en sí (que vive como `terraform.tfstate` en la raíz del proyecto si el backend es local, o permanece intacto en el backend remoto si se usa uno). El siguiente comando exigirá correr `terraform init` de nuevo para redescargar providers/módulos y reconectar el backend, pero ni la infraestructura real ni el Terraform state se ven afectados — no se destruye nada en AWS.
