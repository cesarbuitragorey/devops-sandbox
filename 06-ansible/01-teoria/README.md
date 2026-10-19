# Teoría — Ansible L1: gestión de configuración, arquitectura y primeros playbooks

Siguiente lección → [L2: control de tareas y roles](L2-tasks-control-and-roles.md)

> Nota: el material original del curso incluye elementos interactivos (pestañas, hot spots, videos). Aquí se transcribe el texto que sí estaba disponible; las pestañas o secciones cuyo contenido no llegó en la copia están indicadas donde corresponde.

## Introducción

Desarrolladores y administradores de sistemas usan código para automatizar sistemas operativos, configuraciones de hosts, tareas operativas y más. Usar código hace que los cambios de configuración sean repetibles y estandarizados. La gestión de configuración libera a los desarrolladores de tener que configurar manualmente sistemas operativos, aplicaciones del sistema o software de servidor.

En esta lección se descubren las nociones básicas de la teoría de gestión de configuración y se presenta Ansible: cómo funciona y cómo instalarlo. También se compone un primer playbook "hello world" y se profundiza en detalles como la arquitectura de Ansible, los tipos de conexión, el inventario, la composición de playbooks, las tareas, los módulos y los comandos ad hoc, incluyendo cómo Ansible los ejecuta.

## Gestión de configuración: definiciones básicas

La gestión de configuración es un proceso de gobierno e ingeniería de sistemas que asegura la consistencia entre los activos físicos y lógicos de un entorno operativo. El proceso busca identificar y rastrear individualmente los elementos de configuración, documentando sus capacidades funcionales e interdependencias.

### Automatización vs. orquestación

Entender la diferencia entre automatización y orquestación es esencial para los equipos de TI que quieren implementar una cultura DevOps y mejorar sus procesos. Hay un video sobre las diferencias y un [guion en texto descargable (PDF)](https://elearn.epam.com/assets/courseware/v1/bf05ec55900a8112290c3ee003c888ea/asset-v1:RD_CEE+DevOpsCloud+Ansible_0123+type@asset+block/Cloud_DevOps_Ansible_Lesson_1.1.pdf).

Ansible usa la orquestación de la misma manera. Por ejemplo, una arquitectura de centro de datos o de nube está llena de sistemas distintos: servidores web, servidores de bases de datos, balanceadores de carga, sistemas de monitoreo, sistemas de integración continua, etc. Para realizar cualquier proceso hay que tocar los sistemas en el orden correcto, estimular actualizaciones graduales (*rolling updates*) y desplegar el software correctamente.

Algunas arquitecturas dependen de un proceso maestro que opera como orquestador de todos los recursos del entorno. Algunos frameworks de gestión de configuración usan agentes. Otros pueden trabajar en modelos *push* y *pull*, y se puede elegir el mejor para cada caso.

Como resultado de llevar el sistema (o los elementos de configuración) al estado deseado se obtienen distintos tipos de infraestructura: divergente o congruente.

**Infraestructura divergente.** Las configuraciones manuales de sistemas causan muchos problemas con el tiempo. Cuando los sysadmins gestionan manualmente varios sistemas en una tienda de TI "clásica", invariablemente los sistemas se desincronizan con el tiempo. Esto se conoce como *configuration drift* (deriva de configuración). Es imposible evitar esa deriva si se permiten cambios manuales en los sistemas. Muchas instalaciones de TI pasan por una fase divergente hasta que se reconoce como problema, lo que lleva a intentar crear una infraestructura congruente.

**Infraestructura congruente.** *(El texto de esta pestaña no llegó en la copia.)*

## ¿Qué es Ansible?

Ansible es una herramienta potente de automatización de TI y fácil de aprender. Busca dar grandes ganancias de productividad ante una amplia variedad de retos de automatización. Es muy fácil de usar y a la vez lo bastante potente para automatizar entornos complejos de aplicaciones de TI multicapa.

Con Ansible se pueden manejar tareas repetitivas, dándole al equipo más tiempo para concentrarse en el desarrollo y la innovación. Con Ansible se pueden empezar a hacer tareas reales en minutos gracias a su lenguaje simple y legible por humanos. En conjunto, sus capacidades permiten orquestar todo el ciclo de vida de la aplicación sin importar dónde esté desplegada, y su arquitectura **sin agentes** (*agentless*) garantiza un alto nivel de seguridad.

Hay tres aspectos principales por los que tiene sentido usar Ansible: es **simple**, **potente** y **sin agentes**.

Aprovisionamiento, gestión de configuración, despliegue de aplicaciones, seguridad y cumplimiento (*compliance*) y orquestación son solo algunas de las aplicaciones de Ansible. Pero sus beneficios no se limitan a cómo se usa:

- **Una orquestación que se lleva bien con otros:** combina entornos existentes aprovechando las herramientas actuales, como HP SA, Puppet, Jenkins, etc.
- **Inventarios dinámicos:** capturan todos los servidores sin importar la infraestructura, ubicación, etc. Se verán con más detalle en módulos posteriores.
- **Control de versiones:** los playbooks son texto plano; se tratan como código en el control de versiones existente.
- **Descripción perfecta de la aplicación:** cada cambio puede hacerse mediante playbooks, asegurando que todos estén en la misma página.
- **Lenguaje legible por humanos — YAML:** describe y documenta perfectamente cada aspecto del entorno de la aplicación.
- **Automatización multiplataforma:** soporte sin agentes para los principales sistemas operativos, plataformas de nube y virtualización, y dispositivos de red y almacenamiento.

## Instalación

Ansible tiene varios requisitos. Hay dos tipos de nodos de operación en la infraestructura de Ansible: la **máquina de control** (*control node*) y los **nodos gestionados** (*managed nodes*).

**Máquina de control (nodo).** El único requisito de Ansible en el nodo de control es tener instalado Python 2 (versión 2.7) **o** Python 3 (versiones 3.5 o superiores). A partir de Ansible 5.x (ansible-core 2.12), el proyecto se empaqueta solo para Python 3.8 y posteriores, incluyendo Red Hat, Debian, Ubuntu, macOS, BSDs y Windows bajo una distribución de Windows Subsystem for Linux (WSL). **Windows sin WSL no está soportado de forma nativa como nodo de control.** Más detalles en la [documentación oficial](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html#control-node-requirements).

**Nodos gestionados.** *(El texto de esta pestaña no llegó en la copia.)*

Una vez instalado Ansible, hay que entender cómo funciona. El diagrama del curso muestra las relaciones entre los componentes principales de la automatización con Ansible. En general, Ansible requiere un **archivo de inventario** y un **playbook** para operar con los nodos gestionados.

Por defecto, Ansible habla con las máquinas remotas mediante bibliotecas enchufables (*plugins*). Hay varios tipos de plugins disponibles; se pueden encontrar más en el [repositorio de Ansible](https://github.com/ansible/ansible/tree/devel/lib/ansible/plugins).

### Tipos de conexión

Ansible soporta **OpenSSH** nativo (`ssh`) o una implementación en Python llamada **Paramiko** para conectarse a una máquina basada en Unix. Se prefiere OpenSSH si se usa una versión reciente, y habilita funciones como Kerberos y *jump hosts*.

Otros tipos de conexión, como el modo `accelerate`, deben arrancarse (*bootstrapped*) sobre uno de los tipos de conexión basados en SSH, pero son muy rápidos; el modo `local` actúa sobre el sistema local.

Ansible necesita saber cómo conectarse a los nodos remotos. Puede usar SSH, Paramiko u otros plugins personalizados para conectarse a los servidores gestionados. Hay otros tipos de conexión, incluyendo `local`, `WinRM`, `chroot`, `kubectl`, etc., y siempre se pueden usar plugins de conexión personalizados.

Para ver los plugins de conexión disponibles se usa `ansible-doc -t connection -l`. Para ver su documentación detallada y ejemplos, `ansible-doc -t connection <nombre del plugin>`.

### Entorno de pruebas

Una de las formas más fáciles de armar un entorno de pruebas para aprender Ansible es usar **Vagrant**. Se puede crear un entorno Vagrant propio o usar los disponibles públicamente en https://github.com/svergun/vagrant/tree/master/ansible-workshop. Por supuesto, también se pueden usar otras formas, como la máquina local, instancias en la nube, etc.

### Instalar Ansible

Hay tres formas de instalar Ansible:

1. usando Python PIP
2. usando EPEL
3. ejecutándolo desde el código fuente

**Con Python PIP.** La forma más simple y recomendada. Permite cambiar fácilmente entre las versiones de Ansible requeridas u obtener la última versión:

```
$ pip install Ansible
```

Más detalles en la [documentación oficial](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html#installing-ansible-with-pip). Por cierto, PIP resuelve automáticamente todas las dependencias y, para ser honestos, hay muchísimas.

**Con EPEL.** *(El texto de esta pestaña no llegó en la copia.)*

**Desde el código fuente.** Para ejecutar Ansible desde fuentes hay que seguir los pasos descritos en la [documentación](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html#running-ansible-from-source-devel), con la salvedad de que hay que ocuparse uno mismo de las dependencias antiguas.

Hay que tener cuidado con las distintas versiones de Ansible: nadie puede asegurar que el código desarrollado para la última versión funcione correctamente en versiones anteriores. Se recomienda usar la última versión estable.

Para verificar que Ansible se instaló correctamente se ejecuta `ansible --version`. Muestra la versión instalada y dónde buscará Ansible sus módulos:

```
$ ansible --version
ansible [core 2.11.2] 
  config file = None
  configured module search path = ['/home/vagrant/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
  ansible python module location = /home/vagrant/.local/lib/python3.6/site-packages/ansible
  ansible collection location = /home/vagrant/.ansible/collections:/usr/share/ansible/collections
  executable location = /home/vagrant/.local/bin/ansible
  python version = 3.6.8 (default, Aug 24 2020, 17:57:11) [GCC 8.3.1 20191121 (Red Hat 8.3.1-5)]
  jinja version = 3.0.1
  libyaml = True
```

## Comandos ad hoc

Los comandos *ad hoc* son comprobaciones rápidas que no necesitan conservarse en un playbook de Ansible. Un comando ad hoc usa la herramienta de línea de comandos para automatizar una sola tarea en uno o más nodos gestionados (la máquina local o nodo de control también puede ser gestionada con comandos ad hoc).

¿Por qué aprenderlos primero? Demuestran la simplicidad y el poder de Ansible. Son ideales para tareas que se repiten rara vez. Se pueden usar para reiniciar servidores, copiar archivos, gestionar paquetes y usuarios, y mucho más. Más detalles en la [documentación](https://docs.ansible.com/ansible/latest/user_guide/intro_adhoc.html).

Sintaxis:

```
ansible host_or_group -m module -a "arguments" [-i inventory_file]
```

Por defecto usa el archivo de inventario de `/etc/ansible/hosts`. Para usar otro inventario se especifica la opción `-i`. Si se omite `-m module`, se llama al módulo `shell`.

Ejemplos de casos de uso:

**Comprobar la conectividad con los nodos gestionados:**

```
$ ansible all -i 'node1,node2,node3' -m ping
node1 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/libexec/platform-python"
    },
    "changed": false,
    "ping": "pong"
}
node2 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/libexec/platform-python"
    },
    "changed": false,
    "ping": "pong"
}
node3 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/libexec/platform-python"
    },
    "changed": false,
    "ping": "pong"
}
```

**Reiniciar un nodo gestionado:**

```
$ ansible all -i 'node1,' -a "/sbin/reboot" --become
```

**Ver el uptime de un nodo gestionado:**

```
$ ansible all -i 'node1,' -a "uptime"
node1 | CHANGED | rc=0 >>
 18:22:10 up 0 min,  1 user,  load average: 0.25, 0.09, 0.03
```

**Instalar paquetes en los nodos gestionados:**

```
$ ansible all -i 'node1,node3' -m package -a 'name="nano" state=present' --become
node3 | CHANGED => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/libexec/platform-python"
    },
    "changed": true,
    "msg": "",
    "rc": 0,
    "results": [
        "Installed: nano-2.9.8-1.el8.x86_64"
    ]
}
node1 | CHANGED => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/libexec/platform-python"
    },
    "changed": true,
    "msg": "",
    "rc": 0,
    "results": [
        "Installed: nano-2.9.8-1.el8.x86_64"
    ]
}
```

**Recolectar y mostrar los *facts* descubiertos del localhost o de los nodos gestionados:**

```
$ ansible localhost -m setup
```

Hay un video sobre la sintaxis de comandos de Ansible y un [guion en texto descargable (PDF)](https://elearn.epam.com/assets/courseware/v1/5e2ccccd4308948ef6f4fdc634f2586f/asset-v1:RD_CEE+DevOpsCloud+Ansible_0123+type@asset+block/Cloud_DevOps_Ansible_Lesson_1.2.pdf).

### Salida de Ansible

Hay que fijarse en los colores. Por defecto: **verde** significa que no hubo cambios, **amarillo** que algo cambió, **ámbar** suele usarse para mensajes de advertencia, **cian** para tareas omitidas (*skipped*), y se ve salida **roja** en caso de fallo.

## Inventario

El inventario es una colección de hosts o nodos gestionados contra los cuales Ansible puede ejecutarse. Es un archivo que contiene:

- hosts
- grupos
- datos específicos del inventario (variables)
- fuentes estáticas o dinámicas

El inventario es normalmente un archivo de texto. La ubicación por defecto es un archivo llamado `/etc/ansible/hosts`. Se puede especificar otro archivo de inventario por línea de comandos con la opción `-i <ruta>`. La única excepción es `localhost` en Ansible versión 2 o superior: no hace falta proporcionar un archivo de inventario ni un tipo de conexión para ejecutar Ansible 2+ sobre localhost. También se pueden usar varios archivos de inventario simultáneamente y/o traer el inventario de fuentes dinámicas o de la nube, o de distintos formatos (YAML, ini, etc.).

*(Los ejemplos del curso, "definir un grupo de hosts" y "definir hosts sin agrupar", no llegaron en la copia.)*

## Sintaxis YAML

Para empezar a componer un primer playbook hay que conocer la sintaxis YAML, ya que todos los playbooks de Ansible se escriben en ese formato.

YAML se usa porque es fácil de leer y escribir en comparación con otros formatos de datos como XML o JSON. Además, hay bibliotecas disponibles en la mayoría de los lenguajes de programación para trabajar con YAML.

YAML soporta las siguientes estructuras: listas, diccionarios, listas de diccionarios y variables simples. En las variables simples, por ejemplo, los booleanos pueden definirse con valores `true`-`false` o `yes`-`no`. También es posible añadir JSON crudo, ya que YAML lo entiende.

YAML soporta comentarios: todo lo que sigue al símbolo `#` es un comentario, igual que en Bash. Hay que cuidar las **indentaciones** y **no usar tabuladores**.

**Lista:**

```
# List
Fruits:
  - Apple
  - Orange
  - Strawberry
  - Mango
```

**Diccionario:**

```
# Dictionary
Employee:
  name: Martin
  title: Developer
  skill: Python
```

**Lista de diccionarios:**

```
# List of dictionaries
Contacts:
  - name: user1
    id: 101
  - name: user2
    id: 102
  - name: user3
    id: 103
```

**Variables simples:**

```
# Boolean variables
- create_key: yes
- need_agent: No
- reboot_system: True
- deploy_app: true
- remove_user: false
```

Más información sobre la sintaxis YAML en la [documentación](https://docs.ansible.com/ansible/latest/reference_appendices/YAMLSyntax.html).

## Playbook

Un playbook es una lista de *plays*; cada play contiene *tasks* (tareas), y cada tarea contiene módulos con o sin argumentos. Las tareas invocan *handlers* si su estado es *changed*. Los handlers se ejecutan una vez al final del play en el que están programados. Técnicamente, los handlers son tareas que se describirán por separado más adelante.

Una tarea llama a un módulo y puede tener parámetros. Ansible incluye varios módulos llamados la "biblioteca de módulos", que pueden ejecutarse en hosts remotos o mediante playbooks. Puede haber más de 1400 módulos disponibles para Ansible en un mismo sistema. Estos módulos pueden controlar recursos del sistema como servicios, paquetes y archivos, o ejecutar comandos del sistema. También se pueden escribir módulos propios.

La documentación está disponible en línea o localmente con el comando `ansible-doc <nombre-del-módulo>`; `ansible-doc -l` da la lista de módulos disponibles. La documentación de todos los módulos está en el [índice de colecciones](https://docs.ansible.com/ansible/latest/collections/index.html).

Conviene aprender primero algunos módulos: los **módulos de comandos**, de **archivos**, de **paquetes**, de **sistema** y de **utilidades**. *(La lista de módulos de cada categoría no llegó en la copia.)*

### Sintaxis de los argumentos de un módulo

Ansible reconoce las siguientes tareas como idénticas:

Ejemplo 1:

```
name: Enable Nginx Service
service: name=nginx state=started enabled=yes 
```

Ejemplo 2:

```
name: Enable Nginx Service
service:
  name=nginx
  state=started
  enabled=yes

```

Ejemplo 3:

```
name: Enable Nginx Service
service:
  name: nginx
  state: started
  enabled: yes

```

Para Ansible estos tres ejemplos son lo mismo, pero hay que mantener el mismo estilo de código en todo el playbook.

Hay un video para desarrollar un primer playbook y un [guion en texto descargable (PDF)](https://elearn.epam.com/assets/courseware/v1/84ffd57b5c5f6eddcee3a19d5ab0a05b/asset-v1:RD_CEE+DevOpsCloud+Ansible_0123+type@asset+block/Cloud_DevOps_Ansible_Lesson_1.3.pdf).

### Ejecutar un playbook

Los parámetros más comunes son:

```
ansible-playbook playbook.yml \
-i inventory \        # <- Hosts Inventory File (default=/etc/ansible/hosts)
-c connection_type \  # <- connection type to use (paramiko, ssh, local)
-u username \         # <- connect as this user
-k \                  # <- ask for connection password
-K \                  # <- ask for privilege escalation password
--private-key=id_rsa  # <- file to authenticate the connection
                      #    --private-key == --key-file
-v                    # <-verbose mode (-vv, -vvv, -vvvv)
-e variable=value     # <-set additional variables as key=value
```

Más información en la [documentación de playbooks](https://docs.ansible.com/ansible/latest/user_guide/playbooks.html).

## Escalada de privilegios (*privilege escalation*)

Ansible permite "convertirse" (*become*) en otro usuario distinto del que inició sesión en la máquina (el usuario remoto). Esto se hace con herramientas de escalada de privilegios existentes, que probablemente ya se usan o están configuradas, como `sudo`, `su`, `pfexec`, `doas`, `pbrun`, `dzdo`, `ksu`, `runas`, `machinectl`, etc.

A veces hay que delegar la ejecución del comando en otro usuario del sistema, como hace `sudo`. En ese caso se le dan a la tarea los parámetros `become` y `become_user`.

Si no se indica `become_user: root`, Ansible interpreta que se necesita un superusuario para ejecutar el módulo. Por lo tanto es opcional para `root`, pero para los usuarios que **no** son root se puede especificar en el nivel de tarea o de play, de modo que todas las tareas del playbook se ejecuten con los privilegios de ese usuario de servicio.

```
# In a task: 
- name: Enable Nginx Service
 service: name=nginx state=started enabled=yes
 become: yes
 become_user: root

# In a Play 
- hosts: all
 become: yes
 become_user: 
```
