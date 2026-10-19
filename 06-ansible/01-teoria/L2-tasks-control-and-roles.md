# Teoría — Ansible L2: control de tareas y roles

← [L1: gestión de configuración, arquitectura y primeros playbooks](README.md) · Siguiente → [L3: funciones avanzadas](L3-advanced-features.md)

> Nota: el material original incluye elementos interactivos (diagramas, pestañas, desplegables, videos). Aquí se transcribe el texto disponible; lo que no llegó en la copia está indicado donde corresponde.

## Introducción

En esta lección se repasa la estructura de un playbook de Ansible, se descubren los *handlers* mencionados en la lección anterior, se examina la estructura de un proyecto, se aprende sobre los archivos de inventario, se revisan los roles de Ansible y su uso en proyectos. También se presta atención a las variables, se examinan más de cerca los datos descubiertos (*facts*) y se profundiza en los bucles (*loops*) de Ansible y cómo usarlos.

## Estructura de un playbook

Los playbooks de Ansible ofrecen un sistema de gestión de configuración y despliegue multi-máquina repetible, reutilizable y simple, muy adecuado para desplegar aplicaciones complejas.

El formato de un playbook es bastante directo pero estricto en cuanto a espaciado y disposición. Los playbooks son archivos (o un archivo) donde se escribe el código de Ansible, en formato YAML. Son una de las funciones centrales de Ansible y le dicen qué ejecutar: son como una lista de tareas pendientes (*to-do list*) para Ansible. *(El diagrama de la estructura no llegó en la copia.)*

Además de *plays*, *tasks* y módulos, la estructura de un playbook puede incluir tareas específicas llamadas **handlers**.

## Handlers

Los handlers son como las [tareas](https://docs.ansible.com/ansible/latest/user_guide/playbooks_intro.html#tasks-list) normales de un playbook, pero se ejecutan **solo si una tarea contiene una directiva `notify`**, lo cual indica además que esa tarea cambió algo.

Para entender mejor cómo funcionan, el curso muestra un ejemplo de playbook `playbook-handler.yml` que instala el servidor web Apache y después reinicia el servicio. En ese ejemplo, el handler es notificado para reiniciar Apache justo después de la instalación, usando `notify`. El nombre indicado en `notify` **debe coincidir con el nombre del handler**; de lo contrario habrá errores en el playbook. *(El contenido del archivo de ejemplo no llegó en la copia; sí su salida.)*

En la salida se ve que el handler se ejecuta justo después de la tarea:

```
$ ansible-playbook playbook-handler.yml  

PLAY [HANDLER EXAMPLE] **************************************************************************************** 

TASK [Install Web Server] **************************************************************************************** 

changed: [node2] 

RUNNING HANDLER [restart apache] **************************************************************************************** 

changed: [node2] 

PLAY RECAP **************************************************************************************** 

node2: ok=2  changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0 

```

Más detalles sobre handlers en la [documentación](https://docs.ansible.com/ansible/latest/user_guide/playbooks_intro.html#handlers-running-operations-on-change).

## Variables

Las variables pueden definirse en muchos lugares distintos. Hay varias fuentes:

- Playbooks
- Archivo de inventario
- Línea de comandos (con el argumento `--extra-vars` del comando `ansible-playbook`)
- Variables descubiertas de los *facts* recolectados

Hay un video sobre variables en Ansible y un [guion en texto descargable (PDF)](https://elearn.epam.com/assets/courseware/v1/b06fbe3c414f99f1e752b7de7c24f644/asset-v1:RD_CEE+DevOpsCloud+Ansible_0123+type@asset+block/Cloud_DevOps_Ansible_Lesson_2.1.pdf).

### Precedencia de variables

¿Qué prioridad tienen las variables en Ansible? Ansible ve la lista de variables ordenada de arriba hacia abajo **de menor a mayor prioridad**. *(La lista del diagrama no llegó en la copia.)* Más detalles en la [documentación sobre precedencia](https://docs.ansible.com/ansible/latest/user_guide/playbooks_variables.html#variable-precedence-where-should-i-put-a-variable).

### Variables por línea de comandos

Para pasar variables al comando del playbook se usa el argumento `-e` o `--extra-vars`. Se puede pasar el valor en formato `clave=valor` y unir varias variables en un solo argumento. También se puede dar un archivo de variables en YAML o JSON; hay que anteponer el símbolo `@` al nombre del archivo. Además se puede pasar JSON crudo, que Ansible entiende. Es muy cómodo si se automatizan varias rutinas.

```
$ man ansible-playbook
...
-e VARS, --extra-vars =VARS
Extra variables to inject into a playbook, in key=value key=value format or as quoted JSON (hashes and arrays). To load variables from a file, specify the file preceded by @ (e.g. @ vars.yml).
...

$ ansible-playbook ... -e somevar=somevalue
$ ansible-playbook ... -e "somevar1=somevalue1 somevar2=someval2"
$ ansible-playbook ... --extra-vars @vars.yml
$ ansible-playbook ... --extra-vars @vars.json
$ ansible-playbook ... -e "{'somevar1': 'someval1', 'somevar2': 'someval2'}"

```

> El material original escribe las dos líneas de archivo como `--extra vars=vars=@vars.yml` / `--extra vars=vars=@vars.json`, que no es sintaxis válida; la forma correcta es `--extra-vars @archivo` (o `-e @archivo`), como se muestra arriba.

### Variables registradas (*registered variables*)

Si se desarrollan playbooks complejos, puede hacer falta fijar parámetros mediante variables y usar los datos resultantes en otras tareas, por ejemplo al usar operadores condicionales. Ansible permite reutilizar la salida de una tarea en otras tareas (directiva `register`).

Hay un video sobre el tema y un [guion en texto descargable (PDF)](https://elearn.epam.com/assets/courseware/v1/c28b2c8087e6d54897b3761ea1bfb56b/asset-v1:RD_CEE+DevOpsCloud+Ansible_0123+type@asset+block/Cloud_DevOps_Ansible_Lesson_2.2.pdf). Más detalles en la [documentación](https://docs.ansible.com/ansible/latest/user_guide/playbooks_variables.html#registered-variables).

## Inventario

El archivo de inventario de Ansible define los hosts y grupos de hosts sobre los que operan los comandos, módulos y tareas de un playbook. Tiene dos propósitos:

- Guardar la información de los hosts que se van a gestionar.
- Diseñar la infraestructura para un entorno de desarrollo, *staging* o producción.

El número de hosts puede variar, igual que los nombres de host y algunos ajustes específicos que pueden definirse con variables. Pero la solución general es la misma: hay servidores de aplicación, servidores web y servidores de bases de datos. Se debe desarrollar un playbook que **no dependa del entorno**: la única diferencia debe estar en los archivos de inventario. Por eso es crucial conocer sus características, crearlos bien y gestionarlos eficazmente.

Se ejecuta el playbook con la opción `-i` indicando el archivo de inventario. En el ejemplo se usa el mismo playbook `site.yml` con distintos inventarios:

```
$ ansible-playbook -i production site.yml
$ ansible-playbook -i staging site.yml

```

### Inventario: hosts y grupos

Se pueden añadir variables a un archivo de inventario para definir valores de hosts o grupos de hosts específicos. El curso muestra tres pestañas: *Hosts y grupos*, *Variables de grupo* y *Grupo de grupos* (las dos últimas no llegaron en la copia).

**Hosts y grupos:**

```
mail.example.com

[webservers]
foo.example.com
bar.example.com

[dbservers]
one.example.com
two.example.com
three.example.com
```

**Variables de host** (se pueden tratar como opciones de configuración):

```
[atlanta]
host1 http_port=80 maxRequestsPerChild=808
host2 http_port=303 maxRequestsPerChild=909
```

Más detalles en la [documentación](https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html#adding-variables-to-inventory).

### Inventario: variables en archivos separados

Hay otra forma de guardar variables de grupo y de host: crear las carpetas `group_vars` y `host_vars` en el mismo directorio donde está el archivo de inventario. Cada archivo (con el mismo nombre que el grupo) contiene variables. Más detalles en la [documentación](https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html#organizing-host-and-group-variables).

## Roles

Los roles proveen un marco para colecciones de variables, tareas, archivos, plantillas (*templates*) y módulos, totalmente independientes o interdependientes.

En Ansible, el rol es el mecanismo principal para dividir un playbook en varios archivos. Esto simplifica escribir playbooks complejos y los hace más fáciles de reutilizar: permite dividir el playbook en componentes reutilizables de forma lógica.

Cada rol está esencialmente limitado a una sola funcionalidad o resultado deseado, con todos los pasos necesarios para lograrlo contenidos en ese rol o listados como dependencias en otros roles.

**Los roles no son lo mismo que los playbooks.** Los roles son pequeñas piezas de funcionalidad que pueden usarse de forma independiente pero **deben usarse junto con playbooks**. No hay forma de ejecutar un rol directamente. El host al que se aplicará un rol no se especifica explícitamente dentro del rol.

Cuando se asigna un rol a un grupo de hosts (o a un conjunto de grupos, patrones de hosts, etc.) se les está diciendo que hagan algo específico: aplicar ciertos valores de variables, tareas y handlers concretos, o solo uno o varios de ellos. Los roles se vuelven unidades redistribuibles gracias a la estructura de archivos asociada, lo que permite compartir comportamiento entre playbooks o incluso con otros usuarios.

Un rol es una de las formas en que Ansible permite reutilizar su código. Debe ser portable y autosuficiente. Por ejemplo, el rol "webserver" o "java" trata sobre una configuración asignada al host. Basta con crear una carpeta `roles` en el directorio del playbook y colocar ahí la biblioteca de roles; luego se pueden usar en el proyecto los roles que correspondan a los nombres de carpeta dentro de `roles`.

### Roles: estructura

La estructura de un rol parece muy sofisticada a primera vista, pero en la práctica no es tan complicada. ¿Para qué tantas carpetas?

- **`defaults` y `vars`:** guardan las variables del rol, que van en el archivo `main.yml` de cada carpeta. `defaults` almacena las variables que probablemente se actualicen o redefinan en el playbook; `vars` se usa normalmente para variables complejas o interpoladas. Otra diferencia: **las variables de `vars` tienen mayor prioridad que las de `defaults`**.
- **`handlers` y `tasks`:** guardan los handlers y las tareas del rol, respectivamente. No hace falta especificar las secciones `tasks` ni `handlers` ahí dentro: basta con listar las tareas.
- **`meta`:** guarda las **dependencias** del rol. Por ejemplo, el rol TOMCAT depende del rol Java; y en algunos casos depende de una versión específica de Java. Así se definen las dependencias.
- **`files` y `templates`:** son las carpetas que usan por defecto los módulos `copy` y `template`.
- **`library`:** la usan los módulos personalizados que puede emplear el rol.
- **`tests`:** contiene un inventario y un playbook simples para probar el rol.

Todas estas carpetas son **opcionales**: si no hay nada que poner en `library`, no hace falta crearla; lo mismo para el resto. Por ejemplo, se puede crear un rol que solo consista en una carpeta `library` con módulos propios, y funcionará: todos esos módulos estarán disponibles en el playbook.

Ansible toma los datos de un rol y crea una especie de *playbook en tiempo de ejecución*: las variables de `defaults` y `vars` van a la sección `vars`; `tasks` y `handlers` van a sus secciones respectivas; y `meta`, que contiene las dependencias del rol, va a la sección `roles`.

### Roles: parámetros

Es posible parametrizar los roles añadiendo variables. El curso muestra dos ejemplos de sintaxis equivalentes para Ansible, de modo que se puede elegir el estilo más cómodo. *(Los dos ejemplos no llegaron en la copia.)*

### Roles: orden de ejecución en un playbook

Primero Ansible carga las variables (según la precedencia), recolecta los *facts* (si está habilitado), lanza las tareas de la sección `pre_tasks`, luego las tareas de la sección `roles`, luego las de `tasks`, y después las de `post_tasks`:

1. Carga de variables
2. Recolección de facts
3. Ejecución de `pre_tasks`
4. Handlers notificados desde `pre_tasks`
5. Ejecución de roles
6. Ejecución de tasks
7. Handlers notificados desde roles o tasks
8. Ejecución de `post_tasks`
9. Handlers notificados desde `post_tasks`

Hay que tener en cuenta que **los handlers disparados se ejecutan al final de cada bloque de tareas, no al final del playbook**. Por eso, si un handler se dispara en `pre_tasks`, se ejecuta antes de que empiecen las tareas de los roles.

### Roles: dependencias

Los roles permiten definir otros roles como dependencia, creando un archivo `meta/main.yml` con un bloque `dependencies`:

```
dependencies: 
  - common 

```

También se puede pasar un valor a un parámetro/variable del rol dependiente:

```
dependencies: 
  - { role: apache, apache_port: 80 } 

```

O incluso ejecutar el rol dependiente de forma condicional:

```
dependencies:
  - common
  - { role: apache, apache_port: 80 }
  - { role: postgres, dbname: blarg, other_parameters: 12}

```

### Roles: inicialización

La estructura de carpetas de un rol puede crearse **manualmente** o con **`ansible-galaxy`**.

**Manualmente.** Hay que crear a mano la estructura de directorios y archivos requeridos con comandos del sistema:

```
$ mkdir -p roles/my_role/{defaults,vars,tasks,meta,handlers}
$ touch roles/my_role/{defaults,vars,tasks,meta,handlers}/main.yml

```

Este método no necesita acceso a Internet.

**Con `ansible-galaxy`.** Ansible Galaxy es un repositorio público que aloja roles desarrollados por otros; usarlo requiere acceso a Internet. Por eso necesita tener una carpeta `/tests` con un playbook simple dentro. Aun así, hay que tener cuidado al usar roles de Ansible Galaxy y es mejor desarrollar soluciones propias. Más detalles en la [documentación](https://docs.ansible.com/ansible/latest/user_guide/playbooks_reuse_roles.html#ansible-galaxy).

## Estructura de un proyecto

La estructura de un proyecto se puede componer como se prefiera; la única cuestión es qué considera Ansible como ubicaciones por defecto de las fuentes, a menos que se especifiquen en su archivo de configuración. En la carpeta del proyecto deben estar los archivos de inventario, `production` y `staging`. El curso muestra dos ejemplos de estructura de proyecto *(no llegaron en la copia)*. Más detalles en la [documentación de buenas prácticas](https://docs.ansible.com/ansible/latest/user_guide/playbooks_best_practices.html#directory-layout).

## Datos descubiertos (*facts*)

Como se vio antes, Ansible **recolecta facts** sobre los hosts gestionados cada vez que ejecuta playbooks, por defecto. Hay un video sobre cómo trabajar con esos datos y un [guion en texto descargable (PDF)](https://elearn.epam.com/assets/courseware/v1/c28b2c8087e6d54897b3761ea1bfb56b/asset-v1:RD_CEE+DevOpsCloud+Ansible_0123+type@asset+block/Cloud_DevOps_Ansible_Lesson_2.3.pdf).

## Bucles (*loops*)

Si hace falta repetir una tarea varias veces, se pueden usar los bucles de Ansible. Casos típicos: cambiar el propietario de varios archivos o directorios con el módulo `file`, crear varios usuarios con el módulo `user`, y repetir un paso de sondeo hasta alcanzar cierto resultado.

Ansible no es un lenguaje de programación sino más bien **declarativo**, pero tiene bucles por diseño. Un bucle ejecuta una tarea para una lista de elementos, como crear usuarios o instalar paquetes. Dentro de la tarea se puede referir al elemento actual con la palabra clave `item`. El ejemplo siguiente muestra cómo usar las llaves. Para ahorrar escritura, las tareas repetidas pueden escribirse en forma abreviada:

```
tasks:
  - name: add several users
    user:
      name: '{{ item }}'
      state: present
      groups: wheel
    with_items:
      - testuser1
      - testuser2

  - name: install some packages
    yum: name={{ item }} state=installed
    with_items:
      - httpd
      - java-1.7.0-openjdk-devel
      - java-1.7.0-openjdk

```

> El material original muestra este ejemplo sin la indentación correcta (`- tasks:` y tareas al mismo nivel); arriba está con la estructura YAML válida.

El curso incluye desplegables sobre los distintos tipos de bucle: *Standard Loops*, *Nested Loops*, *Loops: Command Results*, *Loops: Sequences*, *Loops: Together*, *Loops: Random choice*, *Loops: Do-until*, *Register in Loops* y *Loops Control* *(su contenido no llegó en la copia)*. Más detalles en la [documentación de bucles](https://docs.ansible.com/ansible/latest/user_guide/playbooks_loops.html).

## Resumen de la lección

En esta lección se aprendió sobre los **handlers**, similares a las tareas normales pero que se ejecutan si una tarea contiene una directiva `notify` e indica que cambió algo. Se descubrió el **inventario**, que sirve para guardar información de los hosts gestionados, y se miró dentro de la estructura y los parámetros de los **roles**. También se examinaron las **variables** desde el punto de vista de la precedencia, de la más débil a la más fuerte, y su uso en la línea de comandos y en el playbook. Por último se revisó la **estructura de un proyecto** y los **bucles** de Ansible, que se usan para repetir una tarea varias veces.
