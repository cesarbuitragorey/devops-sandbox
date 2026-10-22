# Teoría — Ansible L3: funciones avanzadas

← [L2: control de tareas y roles](L2-tasks-control-and-roles.md) · Siguiente → [L4: gestión de secretos y de la nube](L4-secret-and-cloud-management.md)

> Nota: el material original incluye elementos interactivos (pestañas, desplegables, tarjetas, pasos interactivos, videos). Aquí se transcribe el texto disponible; lo que no llegó en la copia está indicado donde corresponde. Los errores evidentes del original se corrigen con una nota breve.

## Introducción

En esta lección se continúa explorando Ansible: desarrollo de módulos, inventario dinámico, filtros, tests y plantillas de Jinja2, y archivos de configuración de Ansible.

## Desarrollo de módulos

Un **módulo** es un script reutilizable e independiente que Ansible ejecuta en tu nombre, local o remotamente. Los módulos interactúan con la máquina local, una API o un sistema remoto para realizar tareas concretas, como cambiar la contraseña de una base de datos o levantar una instancia en la nube. Cada módulo puede ser usado por la API de Ansible o por los programas `ansible` y `ansible-playbook`.

Un módulo ofrece una interfaz definida: acepta argumentos y devuelve información a Ansible **imprimiendo una cadena JSON por stdout** antes de terminar. Ansible incluye miles de módulos y es fácil escribir los propios. Si el módulo es de uso local, se puede usar cualquier lenguaje de programación y seguir reglas propias.

Más detalles sobre cómo desarrollar y probar módulos en la [documentación](https://docs.ansible.com/ansible/latest/dev_guide/developing_modules_general.html).

### Cómo probar módulos

Desarrollar módulos es desarrollo de software, así que hay que probarlos. El curso presenta tres opciones en pestañas; solo llegó el contenido de la primera:

**Opción 1.** Clonar desde GitHub y ejecutar el script `/ansible/hacking/test-module` con la ruta del módulo, el nombre del módulo y los argumentos.

```
git
clone https://github.com/ansible/ansible.git ansible
Run: ansible/hacking/test-module -m /path/to/module/folder -a args
```

*(Opciones 2 y 3: no llegaron en la copia.)*

Se pueden crear módulos personalizados en Bash, Python o cualquier lenguaje de scripting que el nodo gestionado entienda. Como se vio, para ejecutar un módulo Ansible copia un archivo ejecutable al nodo gestionado y lo corre allí. Por eso los módulos pueden escribirse en cualquier lenguaje y deben ubicarse en la ruta indicada por la variable `ANSIBLE_LIBRARY`, por la opción de línea de comandos `--module-path (-M)` o en el archivo de configuración `ansible.cfg`.

### Ubicación por defecto de los módulos

La ubicación por defecto es **la carpeta donde está el playbook**: se crea un directorio `/library` y ahí se colocan los módulos. La otra opción son las carpetas `/roles/<nombre_del_rol>/library`.

Ojo: a diferencia del sistema operativo, Ansible **falla si hay `module.py` y `module.sh` en la misma carpeta `library`**, porque el nombre del módulo debe ser único. En ese caso los módulos deben llamarse `module_python` y `module_bash`, sin extensión.

### Cómo ejecutar un playbook con módulos personalizados

Hay tres opciones (pestañas); solo llegó la primera:

**Opción 1.** Pasar la opción `-M` con la ruta a la carpeta de módulos.

```
ansible-playbook playbook.yml 
```

> El comando original no incluye `-M`, aunque la opción lo describe; la forma completa sería `ansible-playbook -M <ruta_a_modulos> playbook.yml`.

*(Opciones 2 y 3: no llegaron en la copia.)*

### Módulos personalizados: Bash

Hay dos ejemplos: el primero muestra el comando `date`; el segundo explica cómo Ansible procesa los argumentos y los pasa al módulo *(el segundo no llegó en la copia)*.

El requisito de Ansible es que el módulo **imprima JSON válido**. Si hay algo más que JSON, como espacios inútiles o saltos de línea, Ansible falla.

Se puede llamar a Ansible con `ansible localhost -M <ruta a la librería> -m <módulo>`.

**Módulo de comando simple:**

```
$ cat time_test_bash.sh:

#!/bin/bash
cat << EOF
    "time": "$(date +'%Y-%m-%d %T')" }
EOF


$ ansible localhost -M . -m time_test_bash.sh
localhost | SUCCESS => {
     "changed": false,
     "time": "2020-08-10 10:50:47"
}
```

> El script original omite la llave de apertura `{` del JSON; para que el JSON sea válido debe ser `{ "time": "$(date +'%Y-%m-%d %T')" }`.

### Módulos personalizados: Python

Ejemplo similar, imprimiendo JSON y fecha/hora y cómo probarlo. Ansible ofrece facilidades para gestionar la estructura de los argumentos y proporciona documentación para que los módulos estén disponibles en la utilidad `ansible-doc`. *(Las pestañas "Descripción" y "Ejemplo" mostraban el mismo código; solo llegó el ejemplo.)*

```
$ cat timetest
#!/usr/bin/python                   
import datetime                     
import json                         
date = str(datetime.datetime.now()) 
print json.dumps({                  
        "time":date                 
})

$ ansible localhost -M . -m timetest
localhost | SUCCESS => { 
  "changed": false, 
  "time": "2020-08-10 11:18:01.317904" 
}

```

> `print json.dumps(...)` es sintaxis de Python 2; en Python 3 sería `print(json.dumps({...}))`.

## Inventario dinámico

En una configuración, sobre todo en la nube (por ejemplo AWS), donde el archivo de inventario cambia a medida que se agregan o retiran servidores, llevar el control de los hosts definidos se vuelve un reto. Es incómodo volver al archivo de hosts para actualizar la lista de hosts y sus IPs constantemente.

Ahí entra el **inventario dinámico**: un script escrito en Python, PHP o cualquier otro lenguaje. Es útil en entornos cloud como AWS, donde las IPs cambian cuando un servidor virtual se detiene y se vuelve a iniciar.

Ansible ha desarrollado scripts de inventario para plataformas de nube pública como Google Compute Engine, Amazon EC2, OpenStack, RackSpace, Cobbler y otras.

**Ventajas del inventario dinámico frente al estático:**

- Reducen mucho el error humano, porque la información se obtiene mediante scripts.
- Requieren un esfuerzo mínimo para gestionar los inventarios.

Se puede escribir un inventario dinámico personalizado en el lenguaje que se prefiera. El inventario debe devolver **JSON** cuando se le pasan las opciones adecuadas.

El script debe ser **ejecutable** para que Ansible lo use. A continuación, ejemplos con el script de inventario dinámico de Vagrant y salidas de ejemplo:

```
 $ chmod a+x script.any
```

Para obtener la información de los hosts de un script de inventario dinámico:

```
 $ ./script.any --list
```

*(La salida, en un desplegable, no llegó en la copia.)*

Para obtener la información de un host concreto, usar `--host` con el nombre del host:

```
$ ./script.any --host myhost.example.com
```

*(Salida: no llegó en la copia.)*

Para usar un script de inventario dinámico con `ansible-playbook`, usar la opción `-i` y el nombre del script:

```
$ ansible-playbook ... -i ./script.any ...
```

*(Salida: no llegó en la copia.)*

Más detalles en la [documentación de inventario dinámico](https://docs.ansible.com/ansible/latest/user_guide/intro_dynamic_inventory.html).

## Módulo `add_host`

`add_host` permite **agregar hosts y grupos dinámicamente al inventario en memoria** del playbook durante la ejecución. Así, esos hosts o grupos pueden usarse como destino en los plays siguientes del mismo playbook. Suena confuso, pero es muy útil al trabajar con servidores nuevos que todavía no están en el inventario. Además, se pueden usar variables para representar el nombre de un host o grupo. Esto facilita el trabajo cuando un servidor acaba de construirse y configurarse en el mismo playbook.

Parámetros importantes (tarjetas interactivas):

- **`groups`**: nombre del grupo al que se agregará el host dinámicamente. Alias utilizables: `group name` y `group`.
- **`name`**: nombre o IP del host que se agregará al inventario en memoria. Puede incluir un número de puerto tras dos puntos. Alias utilizables: `hostname` y `host`.

### Cómo funciona `add_host`

Tiene la misma sintaxis YAML que los demás módulos:

```
- name: Adding host to groups
  add_host:
    name: ‹hostname or ip of host›
    groups: ‹group_name›
    myvar: ‹value›

```

El curso incluye un ejemplo paso a paso con un playbook que al comienzo menciona un grupo de hosts `server_list` con un solo host *(el playbook y los pasos no llegaron en la copia; sí la comprobación inicial)*:

```
 > ansible -i hosts server_list --list-hosts   
  hosts (1):
    host-1

> cat hosts 
[server_list]
host-1   ansible_host=127.0.0.1%
```

Más detalles en la [documentación del módulo](https://docs.ansible.com/ansible/latest/modules/add_host_module.html).

## Filtros de Jinja

Un filtro de Jinja2 sirve para **transformar datos** guardados en variables. Se aplican colocando el símbolo de tubería `|` después de la variable, seguido del nombre del filtro. Los filtros pueden cambiar el aspecto y el formato de los datos de origen o incluso generar datos nuevos derivados de los valores de entrada.

El curso incluye un video y un [guion en texto (PDF)](https://elearn.epam.com/assets/courseware/v1/cf2051852be9ff733e53dc9134002618/asset-v1:RD_CEE+DevOpsCloud+Ansible_0123+type@asset+block/Cloud_DevOps_Ansible_Lesson_3.1.pdf). Más detalles en la [documentación de filtros](https://docs.ansible.com/ansible/latest/user_guide/playbooks_filters.html).

## Tests de Jinja

Los **tests** de Jinja2 evalúan expresiones de plantilla y devuelven verdadero o falso. La diferencia con los filtros: **los filtros modifican la estructura de los datos; los tests solo devuelven true/false**. Los tests se usan para comparaciones; los filtros, para manipular datos. Los tests también pueden usarse en filtros de procesamiento de listas como `map()` y `select()` para elegir elementos. Como toda plantilla, **los tests se ejecutan siempre en el controlador de Ansible, no en el destino de la tarea**, porque prueban datos locales. Además de los tests de Jinja2, Ansible aporta algunos más y los usuarios pueden crear los suyos.

Ejemplo (pestañas "Descripción" y "Ejemplo"; solo llegó el ejemplo):

```
vars:
  url: "http://example.com/users/foo/resources/bar"
    
tasks:
  - debug: "msg='matched pattern 1'"
    when: url | match("http://example.com/users/.*/resources/.*")
    
   - debug: "msg='matched pattern 2'"
     when: url | search(*/users/.*/resources/.*)
    
   - debug: "msg='matched pattern 3'"
     when: url | search("/users/"")
```

> Errores del original: indentación inconsistente de las tareas, y comillas mal cerradas en `search(*/users/.*/resources/.*)` y `search("/users/"")`. Además, en versiones modernas de Ansible `match` y `search` se usan como tests: `when: url is match("...")` / `when: url is search("...")`.

Más detalles en la [documentación de tests](https://docs.ansible.com/ansible/latest/user_guide/playbooks_tests.html).

## Plantillas Jinja2

Las plantillas Jinja2 están basadas en Python y se usan para poner **datos específicos del host** en los hosts mediante archivos genéricos YAML y Jinja2. Se utilizan para modificar archivos antes de enviarlos a los hosts gestionados; los datos específicos del host se generan a partir de variables o facts.

El framework de plantillas Jinja soporta variables, filtros, tests, condicionales if-else, bucles for, funciones matemáticas, lógica de comparación, etc. Las variables son las variables normales de Ansible, con dos tipos de sintaxis. Los filtros son los descritos antes (por ejemplo, unir una lista con comas para obtener una cadena). En Jinja también se pueden usar comentarios y sentencias. *(Los ejemplos de sintaxis, en puntos interactivos, no llegaron en la copia.)*

### Ejemplo: crear una configuración de nginx

La tarea es generar una configuración de nginx con este aspecto *(la plantilla y el playbook, en pasos interactivos, no llegaron en la copia)*:

```
http {
  index index.html;

  server {
    server_name www.domain1.com;
    access_log logs/domain1.access.log main;
    root /var/www/domain1.com/htdocs;
  }

  server {
    server_name www.domain2.com;
    access_log logs/domain2.access.log main;
    root /var/www/domain2.com/htdocs;
  }
}
```

Al ejecutar el playbook se obtiene exactamente el archivo de configuración buscado. Más información:

- [Módulo `template`](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/template_module.html)
- [Template Designer Documentation de Jinja](https://jinja.palletsprojects.com/en/3.0.x/templates/)

## Tags

En un playbook grande puede ser útil ejecutar solo una parte de la configuración sin correr todo. Por eso tanto los *plays* como las *tasks* admiten el atributo `tags:`. Cada tarea puede tener varios tags y después se ejecuta el playbook filtrando por tags. El ejemplo ejecuta `example.yml` con los tags `configuration,packages`:

```
tasks:
  - yum: name={{ item }} state=installed
    with_items:
      - httpd
      - memcached
    tags:
      - packages
    
  - template: src=templates/src.j2 dest=/etc/foo.conf
    tags:
      - configuration

$ ansible-playbook example.yml --tags "configuration,packages"
```

Los tags pueden ponerse en plays, roles y tareas:

**Plays**

```
- hosts: webservers
  tags:
    - configuration
   ...

```

**Roles**

```
roles:
  - role: myrole
    tags:
      - configuration
  ...

```

**Tareas**

```
tasks:
  - shell: echo here
    tags:
      - configuration
  ...

```

### Ejemplo de ejecución por tags

Con cuatro tareas, cada una con su propio tag (`a`, `b`, `c`, `d`):

- `ansible-playbook test_tags.yml` ejecuta todo (todos los tags).
- Para ejecutar los tags `a` y `c`: `ansible-playbook test_tags.yml --tags=a,c`
- Para ejecutar todo **excepto** `a` y `c`: `ansible-playbook test_tags.yml --skip-tags=a,c`

### Tags y palabras clave especiales

Los tags `always` y `never` son especiales:

- **`always`**: ejecuta la tarea siempre, salvo que se omita explícitamente (`--skip-tags always`).
- **`never`**: impide que la tarea se ejecute a menos que se pida explícitamente ese tag.

Técnicamente, el módulo `setup` (oculto, el que recolecta facts) está marcado con el tag `always` y se ejecuta siempre. Con este tag especial la tarea se ejecuta aunque no se indique en los tags a ejecutar. El tag `never` solo se menciona de forma introductoria.

También hay tres palabras clave:

- **`tagged`**: ejecuta solo las tareas con tags.
- **`untagged`**: ejecuta solo las tareas sin tags.
- **`all`**: por defecto Ansible ejecuta todo (`--tags all`).

Más detalles en la [documentación de tags](https://docs.ansible.com/ansible/latest/user_guide/playbooks_tags.html).

## El archivo de configuración de Ansible

Ciertos ajustes de Ansible se pueden cambiar mediante un archivo de configuración. La configuración por defecto debería bastar para la mayoría de usuarios, pero puede haber motivos para cambiarla. *(El curso incluye un video con [guion en texto (PDF)](https://elearn.epam.com/assets/courseware/v1/23d268efe39a0969e72011002315c7ec/asset-v1:RD_CEE+DevOpsCloud+Ansible_0123+type@asset+block/Cloud_DevOps_Ansible_Lesson_3.2.pdf); su contenido no llegó en la copia.)*

Más información en la [documentación de configuración](https://docs.ansible.com/ansible/latest/installation_guide/intro_configuration.html).

## Bloques (`block`) y `rescue` para manejo de errores

Los bloques permiten **agrupar lógicamente un conjunto de tareas**, principalmente con dos fines: aplicar lógica condicional (u otras directivas) a todo el conjunto, y manejar errores con `block`, `rescue` y `always`. Con `rescue` se puede ejecutar una acción de limpieza.

### Ejemplo 1: por qué usar bloques

Playbook con cuatro tareas: tres requieren privilegios de root y una no. Se podría usar `become: yes` tres veces, pero eso solo aumenta las líneas de código:

```
---

- name: Ansible Blocks
  hosts: localhost
  gather_facts: false

  tasks:
    - name: List usr directory content
      command: "ls -l /usr"
      become: yes

    - name: List opt partition content
      command: "ls -l /opt"
      become: yes

    - name: List ansible user's home directory content
      command: "ls -l ~"

    - name: List bin diretcory content
      command:  "ls -l /bin"
      become: yes
```

Se podría haber puesto `become: yes` al inicio del play, pero esa escalada de privilegios se aplicaría a todo el play y no se quiere ese permiso para la tarea 3. Con `block` se agrupan las tareas comunes. Aquí se combinaron todas las tareas que necesitan root en un solo bloque, y en vez de usar `become` tres veces se aplica a todo el bloque:

```
---
- name: Ansible Blocks
  hosts: localhost
  gather_facts: false

  tasks:
    - block:
      - name: List usr directory content
        command: "ls -l /usr"

      - name: List opt partition content
        command: "ls -l /opt"

      - name: List bin directory content
        command: "ls -l /bin"
      become: yes

    - name: List ansible user's home directory content
      command: "ls -l ~"
```

Importa la **alineación**: la clave `become` tiene la misma indentación que `block`, así que su valor se aplica a todo el bloque.

### Ejemplo 2: recuperación de errores con `rescue`

Con `block` también se pueden hacer operaciones de recuperación. Normalmente, si una tarea falla el playbook termina (salvo `ignore_errors: yes`). Con `block` se puede asignar un bloque `rescue` con varias tareas que se ejecutan **automáticamente si alguna tarea del bloque falla**. Por último, el bloque `always` se ejecuta **independientemente del estado** de las tareas; sirve, por ejemplo, para dar un resumen o lo que se necesite.

En el playbook siguiente hay dos tareas dentro del bloque: una pasa y la otra falla a propósito. Se ejecuta el bloque `rescue` y después el bloque `always`:

```
---
- name: Ansible Blocks
  hosts: localhost
  gather_facts: false

  tasks:
    - block:
      - name: List home directory content
        command: "ls -l ~"

      - name: Failing intentionally
        command: "ls -l /tmp/does-not-exist"

      rescue:
      - name: Rescue block (perform recovery)
        debug:
          msg: "Something went wrong, cleaning up.."

      always:
      - name: This will execute always
        debug:
          msg: "I will execute even in failure scenario"
```

## Resumen de la lección

En esta lección se vieron los **módulos** de Ansible, incluyendo formas de probarlos y crearlos con Bash y Python. Se exploraron el **inventario dinámico**, los scripts de inventario y el módulo **`add_host`**. Se aprendió sobre los **filtros de Jinja2** (transforman datos dentro de una expresión de plantilla), los **tests de Jinja2** (evalúan expresiones y devuelven true/false) y las **plantillas Jinja**. También se vieron los **tags**, que permiten trabajar una parte de la configuración sin ejecutar todo el playbook, y por último el **archivo de configuración de Ansible** y el manejo de errores con **`block`/`rescue`/`always`**.
