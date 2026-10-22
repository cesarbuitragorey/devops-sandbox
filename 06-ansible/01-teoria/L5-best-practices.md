# Teoría — Ansible L5: buenas prácticas

← [L4: gestión de secretos y de la nube](L4-secret-and-cloud-management.md)

> Nota: el material original incluye elementos interactivos (botones, puntos, pasos). Aquí se transcribe el texto disponible; lo que no llegó en la copia está indicado donde corresponde. Los errores evidentes del original se corrigen con una nota breve.

## Introducción

La única forma probada de aprovechar todo el potencial de Ansible es aplicar las buenas prácticas recomendadas por expertos. Esta lección presenta las **cinco buenas prácticas más importantes** y recomendaciones para **acelerar la ejecución de los playbooks**.

## Buenas prácticas de Ansible

Casi todas las buenas prácticas tienen relación con la filosofía de Ansible: Ansible reduce la complejidad mediante el diseño de la herramienta y te anima a hacer lo mismo.

### 1. Usar `name` en tareas y plays

Siempre hay que poner `name` a los plays y a las tareas. Al ejecutar un play, un nombre con descripción legible comunica mejor la intención a los usuarios. Ejemplo de play sin nombres (en el curso se muestra con su salida en un botón; la salida no llegó en la copia):

```
- name: Ansible Example
  hosts: localhost
  gather_facts: no

  tasks:
    - command: "ls -l ~"

    - debug:
        msg: "This is a test message."

    - copy:
        dest: "/tmp/ansible-test.txt"
        content: |
          This is line 1
          This is line 2

```

Sin saber qué hay dentro del play, otro usuario ve que hace algo con `command` y `copy`, pero ¿qué exactamente? Ni siquiera tiene claro el propósito del play, salvo quizá por el nombre del archivo o por documentación externa.

El mismo ejemplo con `name` declarado en el play y en todas sus tareas:

```
---
- name: Ansible Example
  hosts: localhost
  gather_facts: no

  tasks:
    - name: "List Home Folder"
      command: "ls -l ~"

    - name: "Print Debug Message"
      debug:
        msg: "This is a test message."

    - name: "Create Test File with Content"
      copy:
        dest: "/tmp/ansible-test.txt"
        content: |
          This is line 1
          This is line 2

```

```
$ ansible-playbook ansible-bp-example-10.yml

PLAY [Ansible Example] *******************************************************************************************

TASK [List Home Folder] ******************************************************************************************
changed: [localhost]

TASK [Print Debug Message] ***************************************************************************************
ok: [localhost] => {
    "msg": "This is a test message."
}

TASK [Create Test File with Content] *****************************************************************************
changed: [localhost]

PLAY RECAP *******************************************************************************************************
localhost                  : ok=3    changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

```

Mucho mejor: ahora se ve con claridad, en la propia salida de la ejecución, qué hace el playbook. También ayuda al usar la opción `--list-tasks` de `ansible-playbook`.

### 2. Usar prefijos y nombres con significado en las variables

Ansible tiene un potente sistema de procesamiento de variables que recolecta metadatos de varias fuentes y gestiona su mezcla y contexto mientras un play se ejecuta en los hosts. Se ha puesto mucho esfuerzo en que ese poder sea lo más fácil y transparente posible.

El alcance (*scoping*) y el espacio de nombres (*namespacing*) de las variables se limitaron **a propósito** y son poco profundos, para que sean más fáciles de entender y depurar.

La limitación de este enfoque es el riesgo de **colisión de variables** si dos datos distintos, como un número de puerto, se guardan con el mismo nombre. (Que un servidor web escuche en el puerto 22 no es la diversión que se busca.)

Como buena práctica se recomienda **prefijar las variables con el origen o destino del dato** que representan. Prefijar es especialmente importante al desarrollar roles reutilizables y portables.

También se mejora mucho la legibilidad de playbooks y roles, a cambio de algo de verbosidad, usando **nombres con significado humano** que comuniquen su propósito y uso a otros, o incluso a uno mismo más adelante. *(Los ejemplos de esta sección, si los había, no llegaron en la copia.)*

### 3. Usar sintaxis YAML nativa

En el fondo, el ejecutor de playbooks de Ansible es un parser YAML con lógica añadida, como la abreviatura `clave=valor` de la línea de comandos. Aunque es cómoda al escribir rápido un playbook o un ejemplo de documentación, ese estilo **reduce la legibilidad** y según las buenas prácticas debe evitarse.

Ejemplo de tareas con la abreviatura `key=value`:

```
- name: Install Telegraf
  yum:
    name: telegraf-{{ telegraf_version }} state=present update_cache=yes disable_gpg_check=yes enablerepo=telegraf
  notify: restart telegraf

- name: Configure Telegraf
  template: src=telegraf.conf.j2 dest=/etc/telegraf/telegraf.conf
  notify: restart telegraf

- name: start Telegraf
  service: name=telegraf state=started enabled=yes 

```

*(El curso muestra las otras dos pestañas con la versión en YAML nativo; no llegaron en la copia.)*

El YAML nativo tiene más líneas, pero son más cortas: se reduce el desplazamiento horizontal y el ajuste de línea, lo que permite recorrer el play con la vista de arriba abajo. Los parámetros de las tareas quedan apilados y se distinguen fácilmente de la tarea siguiente. Además el YAML nativo se beneficia de un mejor resaltado de sintaxis en prácticamente cualquier editor moderno: editores como vim y Atom resaltan las claves YAML (nombres de módulo, directivas y nombres de parámetros) distintas de sus valores.

### 4. Usar módulos

La buena práctica más común es **ir siempre a los módulos de Ansible**, es decir, usar las tareas disponibles en lugar de `command` o `shell`. Sobre todo porque los módulos son **idempotentes** de fábrica. A veces no se puede evitar ejecutar un comando en un shell aparte, pero en su mayoría Ansible tendrá el módulo adecuado. Hay que mantenerse alejado de `command` y `shell` **si es posible**.

### 5. DRY (*Don't Repeat Yourself*)

Ansible se parece a un lenguaje de programación normal y, como tal, tiene mecanismos para ser DRY. Requiere planificar el código con antelación: al escribirlo, pensar cómo hacerlo reutilizable.

Se puede reutilizar código con estas directivas (el curso las muestra como elementos con más información cada uno; el detalle no llegó en la copia):

- `import_playbook`
- `import_role`
- `include_role`
- `import_tasks`
- `include_tasks`

Ejemplo: se usa el módulo `uri` para enviar peticiones a una API, por ejemplo peticiones `POST`. En vez de repetir `uri` 10 veces con todos sus ajustes, se crea algo parecido a un "método" y se usa en cualquier lugar. Como un método de un lenguaje normal, también acepta parámetros de entrada.

Archivo reutilizable (`send_post.yml`):

```
- name: Send POST Request  
  uri:
    url: "{{ URL }}"
    method: POST
    status_code: 200
    body: "{{ BODY_VAR | to_nice_json }}"
    body_format: json
    validate_certs: yes
    client_cert: tls.crt
    client_key: tls.key
    register: return_values

```

> En el original `register: return_values` aparece indentado como parámetro de `uri`; `register` es una directiva de la tarea y debe ir al mismo nivel que `uri` (y `name`).

Este es código reutilizable que se puede llamar en cualquier momento. `URL` y `BODY_VAR` son los "parámetros del método":

```
- name: Another Playbook Task
  include_tasks: send_post.yml
  vars:
    URL: "{{ main_url }}/{{ item }}"
    BODY_VAR: "My JSON"

```

El nombre `send_post.yml` no figura explícitamente en el original para el primer bloque, pero es el archivo que referencia el `include_tasks`.

Más detalles en la [documentación de buenas prácticas](https://docs.ansible.com/ansible/2.8/user_guide/playbooks_best_practices.html).

## Cómo acelerar la ejecución de un playbook

Si se ejecuta un playbook contra un gran número de nodos gestionados (por ejemplo, más de 100 hosts), puede tardar mucho si Ansible no está afinado. Ansible tiene varios parámetros configurables que pueden reducir de forma significativa el tiempo de ejecución: del orden de **horas a minutos**.

### 1. Forks

Los *forks* son el número de procesos en paralelo que se usan para comunicarse con los nodos remotos. El valor por defecto es **5** (suficiente en la mayoría de los casos, sobre todo para aprender). Se puede aumentar según la configuración del nodo de control.

Aumentar los forks suele permitir que las tareas se ejecuten más rápido al hacer más trabajo en paralelo. La contrapartida es que aumenta la carga del sistema, lo que podría ralentizar el trabajo en conjunto. En la práctica, un buen valor puede ser **25 o incluso 100**.

Sea cual sea el valor, Ansible es inteligente: si hay 50 nodos gestionados y se ponen 500 forks, solo levantará 50, porque sabe que no necesita más.

Los forks se gestionan con las opciones `-f` o `--forks` de `ansible-playbook`, o en el archivo de configuración de Ansible.

> El original nombra la directiva de configuración como `fork`; en `ansible.cfg` la clave es `forks` (en `[defaults]`).

### 2. Recolección de facts (*gather facts*)

Los facts de Ansible son datos recolectados sobre los nodos gestionados y devueltos al nodo de control. Se guardan en formato JSON y se usan para tomar decisiones importantes sobre las tareas a partir de sus estadísticas. Están en la variable `ansible_facts`, gestionada por Ansible. Son datos y propiedades del sistema específicos del host al que se conecta: la dirección IP, información de BIOS, información sobre el software o incluso el hardware. Ayudan al administrador a gestionar los hosts según su estado actual, en lugar de actuar sin información sobre la salud del sistema.

**Desactivar los facts puede ahorrar mucho tiempo** al ejecutar el playbook contra un grupo de servidores. Pero si en el playbook se usan variables de Ansible que dependen de ellos, no se pueden desactivar.

Ejemplo de cómo desactivar la recolección de facts en el playbook:

```
---
- hosts: all
  gather_facts: no

  tasks:
    - name: Install web server
      yum:
       name: nginx
       state: present

```

Si hace falta recolectar facts y hay cientos de nodos gestionados, conviene pensar en **cachear los facts**, lo que mejora el rendimiento. Con miles de hosts se puede configurar la caché de facts para que se ejecute cada noche y gestionar la configuración de un conjunto menor de servidores periódicamente durante el día. Los facts en caché dan acceso a variables e información de todos los hosts, incluso cuando solo se gestiona un número pequeño de servidores.

Ejemplo de caché de facts en `ansible.cfg`:

```
[defaults]
### Caching Facts
gathering = smart
fact_caching = jsonfile
fact_caching_connection = ./cachedir
fact_caching_timeout = 86400

```

### 3. Pipelining

El *pipelining* reduce el número de operaciones de red necesarias para ejecutar un módulo, ejecutando muchos módulos de Ansible **sin transferir archivos**. Activarlo puede mejorar el rendimiento de forma significativa.

Por defecto, Ansible envía los módulos por una conexión SSH del controlador a la máquina anfitriona, lo que implica (pasos mostrados al hacer scroll):

1. crear un directorio en el nodo gestionado
2. transferir el código fuente del módulo
3. ejecutar el código

El pipelining reduce el número de operaciones `ssh` necesarias ejecutando varios módulos sin transferencia real de archivos. Se usa para reducir el número de conexiones SSH al host a **una por tarea**. El módulo se ejecuta pasando las instrucciones al host por SSH: se escriben directamente en el canal `STDIN`.

Se activa añadiendo `pipelining = True` en el bloque `[ssh_connection]` de `ansible.cfg`, o con las variables de entorno `ANSIBLE_PIPELINING` y `ANSIBLE_SSH_PIPELINING`.

También hay que asegurarse de que **`requiretty` esté desactivado en `/etc/sudoers`** del host remoto; de lo contrario, `become` no funcionará con el pipelining activado.

### 4. Estrategia `free`

Las **estrategias** controlan cómo se ejecuta un play sobre los hosts indicados en un playbook. Por defecto los plays usan la estrategia **`linear`**: todos los hosts ejecutan cada tarea antes de que ningún host empiece la siguiente.

El curso muestra un playbook de ejemplo con varios hosts *(el playbook no llegó en la copia)*, con dos tareas que se ejecutan en cada host en paralelo. La primera tarea empieza en `webserver` y `dbserver` en paralelo. Si `apache2` ya está instalado en `webserver`, este tiene que esperar a que se instale en `dbserver`: `webserver` no puede pasar a la "Second Task" hasta que la instalación termine en `dbserver`. Esa forma de instalar aplicaciones en distintos hosts es la estrategia **LINEAR**, activada por defecto.

Si se necesita instalar o configurar una aplicación de forma independiente en distintos hosts, sin dependencia entre ellos, también es posible: es la estrategia **FREE**. En ella los hosts no dependen unos de otros para completar las tareas; por ejemplo, `webserver` no espera a que una tarea termine en `dbserver`.

> El material no muestra cómo se activa. En Ansible se declara en el play con `strategy: free` (o globalmente con `strategy = free` en `ansible.cfg`); es un dato ajeno al texto de la lección.

## Resumen de la lección

Se exploraron algunas buenas prácticas de Ansible (nombrar plays y tareas, prefijos y nombres significativos en variables, YAML nativo, usar módulos en vez de `command`/`shell`, y DRY) y se vieron varias formas de acelerar la ejecución de playbooks: forks, desactivar o cachear facts, pipelining y estrategia `free`.
