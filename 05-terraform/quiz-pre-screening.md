# Quiz de DevOps Bootcamp — Terraform Pre-Screening (25 preguntas + 2 bonus)

Preguntas, respuestas correctas y explicaciones. Quiz de pre-screening para el módulo de Terraform — state, variables, providers, módulos, outputs, funciones, for_each/count y buenas prácticas.

---

### 1. Borraste un recurso del archivo de configuración de Terraform. Ese recurso todavía existe y hay un registro en el state file sobre él. Luego corres `terraform destroy`. ¿Qué pasará?
- Terraform destruirá todos los recursos presentes en el archivo de configuración. El recurso borrado no será destruido.
- Terraform destruirá solo el recurso borrado. Ningún otro recurso se verá afectado.
- Terraform lanzará un error. No pasará nada hasta que alinees el archivo de configuración con el state file.
- Terraform destruirá todos los recursos presentes en el state file, incluido el recurso borrado de la configuración.

**Respuesta correcta:** Terraform will destroy all resources that are present in state file including the resource deleted from configuration file.
**Por qué:** `terraform destroy` se basa en el state file, no en el archivo de configuración. Como el recurso eliminado sigue registrado en el state, Terraform lo considera parte de la infraestructura administrada y lo destruirá junto con todos los demás recursos presentes en el state.

### 2. Código:
```hcl
variable "nodes" {
  type = number
  default = 10
}
```
¿Qué valor tendrá la variable "nodes" después de ejecutar `terraform apply -var="nodes=1"`?
- 1
- 10
- Este comando resultará en un error.
- null

**Respuesta correcta:** 1
**Por qué:** Cuando se pasa un valor a través de la flag `-var` en la línea de comandos, ese valor tiene mayor precedencia que el `default` definido dentro del bloque `variable`. Por lo tanto, aunque el default sea 10, el valor pasado explícitamente (1) es el que Terraform utilizará.

### 3. ¿Por qué usarías el comando `terraform fmt`?
- Permite formatear automáticamente las configuraciones de Terraform para legibilidad y consistencia.
- Limpia la caché de despliegue de Terraform.
- Revisa el plan de despliegue y formatea la configuración después.
- Descarga todas las dependencias requeridas por la configuración.

**Respuesta correcta:** It allows to automatically format Terraform configurations for readability and consistency.
**Por qué:** `terraform fmt` reescribe los archivos de configuración con un estilo canónico y formato consistente (indentación, alineación de "=", espaciado), lo que facilita la lectura y mantiene consistencia entre todos los archivos .tf del proyecto.

### 4. ¿Cómo devuelve un módulo de Terraform outputs para que los use el código principal?
- Usando recursos "output" en el código del módulo.
- Exportándolos como variables de entorno.
- Los módulos no pueden compartir outputs con la configuración principal.
- Los outputs se guardan en Git para referenciarlos en la configuración principal.

**Respuesta correcta:** Using "output" resources in the code of the module.
**Por qué:** Un módulo expone valores hacia la configuración que lo invoca mediante bloques `output`. Estos bloques definidos dentro del módulo permiten que, una vez ejecutado, sus valores queden disponibles para ser referenciados desde el código principal usando `module.<nombre>.<output>`.

### 5. ¿Cuál de estos es el caso de uso correcto para un loop "for_each"?
- Desplegar una instancia de un módulo usando un map.
- Desplegar instancias idénticas de un módulo.
- Las 3 opciones son correctas.
- Desplegar una instancia de un módulo usando una lista.

**Respuesta correcta:** Deploying an instance of a module using a map.
**Por qué:** `for_each` está diseñado para trabajar con un map o un set de strings, permitiendo crear una instancia por cada clave/valor, cada una con un identificador único. Es ideal cuando cada instancia necesita un identificador distinto (clave), a diferencia de `count` (instancias idénticas) o una lista (que requiere `toset()` para convertirse).

### 6. ¿Por qué un `terraform plan` válido podría fallar al hacer `apply`?
- Las 3 opciones son correctas.
- Un error en el uso de una función.
- Un error en el uso de una variable.
- Un recurso especificado en la configuración de Terraform fue creado manualmente de antemano.

**Respuesta correcta:** A resource specified in the Terraform configuration was created manually beforehand.
**Por qué:** Un plan válido puede fallar al aplicarse por razones externas al código: si un recurso con el mismo nombre/identificador ya existe (creado manualmente o fuera de Terraform), el proveedor cloud rechazará la creación por conflicto, causando que el apply falle aunque el plan fuera técnicamente válido. Errores de función o de variable se detectan antes, en plan/validate, no después de tener un plan válido.

### 7. ¿Cómo se define el valor de una variable al correr `terraform apply` si no tiene un valor por defecto?
- No se puede establecer el valor de una variable de esa forma.
- `terraform apply -var="variable=value"`
- `terraform apply -TFVAR="variable=value"`
- `terraform apply -TFVAR="variable" -TFVALUE="value"`

**Respuesta correcta:** terraform apply -var="variable=value"
**Por qué:** La sintaxis correcta y real de Terraform para pasar el valor de una variable por línea de comandos es usando la flag `-var` seguida de `"nombre_variable=valor"`. La convención `TF_VAR_<nombre>` existe pero se usa como variable de entorno, no como flag de línea de comandos.

### 8. ¿Dónde puedes descargar o referenciar módulos de Terraform en la configuración? (Selección múltiple)
- Sitio web oficial de Terraform.
- Terraform Registry
- Usando el comando "terraform install" en el directorio de trabajo de tu configuración para instalar el módulo y referenciarlo por su nombre.
- Máquina local

**Respuesta correcta:** Terraform Registry; Local machine
**Por qué:** El Terraform Registry (registry.terraform.io) es el repositorio público oficial donde se publican y desde donde se pueden referenciar módulos, usando el atributo `source`. Terraform también permite referenciar módulos almacenados localmente en el sistema de archivos usando una ruta relativa. El comando "terraform install" no existe.

### 9. ¿Qué función de Terraform devuelve una lista de archivos de un directorio dado un path y un patrón?
- fileset
- dirname
- file
- lookup

**Respuesta correcta:** fileset
**Por qué:** La función `fileset(path, pattern)` de Terraform devuelve un conjunto (set) de nombres de archivo que coinciden con un patrón glob dentro de una ruta dada. Es muy usada junto con `for_each` para crear recursos a partir de archivos en un directorio.

### 10. ¿Cómo se obtienen (source) los providers de Terraform? (Elige 3)
- Un archivo separado providers.list dentro del directorio de trabajo.
- Referencia a un provider en un registro interno en los archivos de configuración de Terraform.
- Referencias locales en la configuración de Terraform.
- Por defecto, Terraform busca providers en el registro oficial de providers de Terraform.

**Respuesta correcta:** Reference to a provider in an internal registry in Terraform configuration files; Local references in Terraform configuration; By default, Terraform searches for providers in the official Terraform provider registry.
**Por qué:** Por defecto Terraform busca providers en el Terraform Registry oficial. También es posible especificar un registro interno/privado de una organización dentro de `required_providers`, o configurar filesystem mirrors para obtener providers desde el sistema de archivos local. El archivo "providers.list" no existe.

### 11. Solo tienes el state file de una infraestructura existente (terraform.tfstate). Necesitas eliminar esa infraestructura. ¿Qué deberías hacer?
- Primero deberías importar los recursos al state y describirlos en una configuración. Luego puedes destruir tus recursos.
- Necesitas proveer el bloque terraform y la configuración de providers también. Luego simplemente correr el comando `terraform destroy`.
- Correr el comando `terraform apply -destroy=path_to_state_file`.
- Usar el comando `terraform state rm` para destruir todos los recursos del state file.
- Puedes simplemente correr `terraform destroy` o `terraform apply` dentro de la carpeta que contiene el state file. Luego Terraform elimina tu infraestructura.

**Respuesta correcta:** You need to provide terraform block and providers configuration as well. Then just run `terraform destroy` command.
**Por qué:** Para que `terraform destroy` funcione, Terraform necesita el bloque `terraform` (con `required_providers`) y la configuración del provider, ya que necesita comunicarse con la API del cloud para eliminar los recursos. No es necesario importar ni describir cada recurso en la configuración, pero sí configurar el provider.

### 12. ¿Qué le hará el comando `terraform taint aws_instance.vm` a un recurso llamado "aws_instance.vm"?
- El recurso será marcado como tainted en el state file, borrado y recreado (de inmediato).
- El recurso será marcado como tainted y la corrupción se arreglará automáticamente.
- El recurso será marcado como tainted en el state file. Será borrado y recreado después del siguiente `terraform apply`.
- No hará nada — no puedes marcar como tainted recursos de AWS.

**Respuesta correcta:** The resource will be tainted in the state file. It will be deleted and recreated after the next terraform apply.
**Por qué:** `terraform taint` marca un recurso en el state file como "tainted", pero no ejecuta ninguna acción inmediata. Solo hasta que se corre `terraform apply`, Terraform destruye y vuelve a crear ese recurso específico.

### 13. ¿Cómo se pueden usar las output variables de Terraform? (Elige 3)
- Un módulo hijo puede usar el output con una configuración secundaria para aplicar la configuración en pasos.
- Un módulo hijo puede usar outputs para pasar algunos atributos de sus recursos a un módulo padre.
- Un módulo raíz puede usar outputs para imprimir valores importantes en la terminal después de correr "terraform apply", como referencia.
- Los outputs del módulo raíz pueden pasarse a otras configuraciones vía un data source `terraform_remote_state`.

**Respuesta correcta:** A child module can use outputs to pass some attributes of its resources to a parent module.; A root module can use outputs to print important values in terminal after running "terraform apply" for reference.; Root module outputs can be passed to other configurations via a terraform_remote_state data source.
**Por qué:** Un módulo hijo expone valores hacia el módulo padre mediante outputs. Los outputs del módulo raíz se imprimen automáticamente en terminal al finalizar apply. Y pueden ser consumidos por otras configuraciones separadas mediante `terraform_remote_state`.

### 14. ¿Qué hace `terraform refresh`?
- Lee la configuración actual de todos los recursos gestionados y actualiza el Terraform state en consecuencia.
- Limpia la caché en el directorio de trabajo y corre `terraform plan` después.
- Permite actualizar la caché de módulos y providers de acceso público.
- Verifica la conectividad hacia tu remote state.

**Respuesta correcta:** It reads the current configuration from all managed resources and updates the Terraform state in accordance.
**Por qué:** `terraform refresh` consulta el estado real de la infraestructura en el proveedor cloud y actualiza el state file para que refleje ese estado actual, sin modificar la infraestructura real ni el código. Útil para detectar drift.

### 15. ¿Cuál de estas variables de entorno puedes usar para mostrar los logs de debug más detallados al usar Terraform?
- TF_LOG_EXTREME=DEBUG
- TF_LOG=TRACE
- TF_LOG_LEVEL=HIGHEST
- TF_LOG=LOW

**Respuesta correcta:** TF_LOG=TRACE
**Por qué:** La variable de entorno `TF_LOG` controla el nivel de logging de Terraform (TRACE, DEBUG, INFO, WARN, ERROR). TRACE es el nivel más detallado/verboso disponible.

### 16. ¿Por qué no se pueden usar referencias al output de un recurso en los argumentos "count" o "for_each"?
- Las 3 opciones son correctas.
- Terraform tiene precauciones especiales para evitar loops de error por referenciar outputs o recursos que aún no han sido desplegados.
- Terraform calcula count y for_each en la fase de plan — antes de que se cree o modifique cualquier recurso. El resultado es que esos outputs no pueden calcularse en la fase de plan.
- Aunque los outputs se generan, estos argumentos no los toman en cuenta al calcular la lógica.

**Respuesta correcta:** Terraform computes count and for_each in the plan phase - before any resources are created or changed. The result is these outputs can't be calculated in the plan phase.
**Por qué:** Terraform necesita resolver el valor de `count` y `for_each` durante la fase de plan, antes de crear o modificar cualquier recurso. Un output de un recurso solo existe después de que ese recurso ha sido creado (fase de apply), por lo que no se puede usar un valor que aún no existe.

### 17. ¿Qué hace el comando `terraform plan`?
- Calcula y presenta un plan de las acciones que se tomarán durante el despliegue.
- Permite a los equipos compartir sus planes de despliegue entre máquinas.
- Formatea automáticamente tu configuración de Terraform.
- Permite mapear recursos ya desplegados hacia los recursos declarados en la configuración de Terraform.

**Respuesta correcta:** It calculates and presents a plan of the actions that will be taken during deployment.
**Por qué:** `terraform plan` compara el estado actual (state) con la configuración deseada y genera una vista previa mostrando exactamente qué recursos serán creados, modificados o destruidos, sin ejecutar ningún cambio real.

### 18. ¿Qué significa el siguiente código?
```hcl
node_count = var.env == "prod" ? 10 : 2
```
- Si el valor de la variable env es igual a "prod", "node_count" será 10. De lo contrario, será 2.
- Esto es un snippet de código en Rust.
- El valor de "node_count" será igual al valor de la variable "env", que a su vez será igual al valor de la variable "prod".
- "node_count" será igual al valor de la variable "env".

**Respuesta correcta:** If the value of the env variable equals prod, the "node_count" will be set to 10. Otherwise, it will be set to 2.
**Por qué:** El código usa el operador ternario condicional de Terraform: `condición ? valor_si_verdadero : valor_si_falso`. Si `var.env` es igual a "prod", `node_count` toma el valor 10; si no, toma el valor 2.

### 19. Observa este código en un hipotético prod-module:
```hcl
output "superman" {
  value = "5"
}
```
¿Cómo referenciarías el valor de este output en la configuración principal de Terraform?
- var.superman
- outputs.superman
- No se puede pasar de vuelta a la configuración principal.
- module.prod-module.superman

**Respuesta correcta:** module.prod-module.superman
**Por qué:** Cuando un output está definido dentro de un módulo (llamado "prod-module"), la sintaxis correcta para referenciarlo desde la configuración principal es `module.<nombre_del_módulo>.<nombre_del_output>`.

### 20. Identifica un caso de uso para los data sources.
- Obtener datos sobre los rangos de IP permitidos en una regla de firewall gestionada por otra configuración de Terraform.
- Las 3 opciones son correctas.
- Obtener el contenido de un archivo dentro del directorio de trabajo.
- Obtener la dirección IP de un servidor usando el nombre de la instancia.

**Respuesta correcta:** All 3 choices are correct.
**Por qué:** Los data sources permiten consultar información de recursos existentes que no son gestionados directamente por la configuración actual. Las 3 opciones son casos de uso válidos: leer datos de otra configuración de Terraform, leer contenido de un archivo local, y consultar dinámicamente el IP de un servidor por su nombre.

### 21. ¿Cómo describirías el registro público de Terraform?
- Un repositorio de acceso público de todos los proyectos de HashiCorp Terraform.
- Un servicio de suscripción con un repositorio que permite usar módulos y providers propietarios.
- Un repositorio de paquetes de Linux con múltiples versiones de los binarios de Terraform.
- Un repositorio de acceso público de providers y módulos de Terraform.

**Respuesta correcta:** A publicly accessible repository of Terraform providers and modules.
**Por qué:** El Terraform Registry (registry.terraform.io) es un repositorio público y gratuito donde HashiCorp y la comunidad publican providers y módulos reutilizables que cualquiera puede referenciar en sus configuraciones.

### 22. ¿Cómo se define la configuración del remote state de Terraform?
- No es necesario especificar su configuración, Terraform se encarga de eso.
- En un archivo "tfstate" separado.
- Es requerido definirlo en el "backend" del bloque "terraform" en la configuración.
- En un archivo backend.tf separado.

**Respuesta correcta:** It is required to be defined in the "backend" of the "terraform" block in the configuration.
**Por qué:** La configuración del remote state se define dentro de un bloque `backend` anidado en el bloque `terraform`, especificando el tipo de backend y sus parámetros. Puede estar en cualquier archivo .tf, pero debe estar dentro del bloque `terraform {}`. Usar un archivo llamado backend.tf es solo convención, no un requisito técnico.

### 23. ¿Por qué usarías el valor "ignore_changes" en un recurso?
- Todos los atributos en la lista "ignore_changes" pueden cambiar sin que Terraform intente actualizar el recurso.
- Todos los atributos en la lista "ignore_changes" pueden tener tipos de dato inválidos (ej. un número en vez de un string), y "terraform apply" seguirá funcionando. La API puede seguir fallando.
- Todos los atributos en la lista "ignore_changes" solo se aplicarán en el workspace por defecto.
- Todos los módulos en la lista "ignore_changes" no se usarán durante "terraform apply".

**Respuesta correcta:** All attributes in the "ignore_changes" list can change without triggering Terraform to update the resource.
**Por qué:** `ignore_changes` (dentro del bloque `lifecycle`) le indica a Terraform que ignore diferencias detectadas en los atributos especificados. Útil cuando un valor puede cambiar fuera de Terraform y no queremos que Terraform intente "corregirlo" en cada apply.

### 24. ¿Cuál de estas es la mejor descripción de un provider de Terraform?
- Un plugin que permite a Terraform trabajar con la capa de API de una plataforma cloud o una herramienta.
- Una feature adicional que permite a Terraform agregar variables a los módulos.
- Una herramienta que permite a Terraform actualizar su propio binario.
- Un mecanismo que lista el árbol de dependencias requeridas para que un módulo funcione.

**Respuesta correcta:** A plugin that allows Terraform to work with the API layer of a cloud platform or a tool.
**Por qué:** Un provider es un plugin que Terraform utiliza para comunicarse con las APIs de un proveedor cloud (AWS, Azure, GCP) o de cualquier otra plataforma/herramienta, traduciendo la configuración HCL en llamadas reales a esas APIs.

### 25. ¿Por qué almacenarías el Terraform state de forma remota?
- Agilidad, optimización de memoria, parcheo automatizado del código de configuración.
- Los despliegues de Terraform se completarán más rápido.
- Permite acceso granular, disponibilidad, integridad, seguridad y colaboración.
- Es lo mismo que almacenar el state localmente.

**Respuesta correcta:** It allows for granular access, availability, integrity, security, and collaboration.
**Por qué:** Almacenar el state remotamente permite controlar el acceso mediante permisos granulares, tener alta disponibilidad, mantener integridad mediante locking, mejorar la seguridad, y habilitar la colaboración entre varios miembros del equipo.

---

## Preguntas bonus (repetidas durante el quiz)

### Bonus 1 (repite la pregunta 19). Observa este código en un hipotético prod-module:
```hcl
output "superman" {
  value = "5"
}
```
¿Cómo referenciarías el valor de este output en la configuración principal de Terraform?
- var.superman
- outputs.superman
- No se puede pasar de vuelta a la configuración principal.
- module.prod-module.superman

**Respuesta correcta:** module.prod-module.superman
**Por qué:** Pregunta repetida durante el quiz (coincide con la pregunta 19 original). Se confirma la misma respuesta: `module.prod-module.superman`, siguiendo la sintaxis `module.<nombre_del_módulo>.<nombre_del_output>`.

### Bonus 2 (repite la pregunta 24). ¿Cuál de estas es la mejor descripción de un provider de Terraform?
- Un plugin que permite a Terraform trabajar con la capa de API de una plataforma cloud o una herramienta.
- Una feature adicional que permite a Terraform agregar variables a los módulos.
- Una herramienta que permite a Terraform actualizar su propio binario.
- Un mecanismo que lista el árbol de dependencias requeridas para que un módulo funcione.

**Respuesta correcta:** A plugin that allows Terraform to work with the API layer of a cloud platform or a tool.
**Por qué:** Pregunta repetida durante el quiz (coincide con la pregunta 24 original). Se confirma la misma respuesta: un provider es un plugin que permite a Terraform comunicarse con la API de una plataforma cloud o herramienta.
