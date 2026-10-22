# Teoría — Ansible L4: gestión de secretos y de la nube

← [L3: funciones avanzadas](L3-advanced-features.md)

> Nota: el material original incluye elementos interactivos (pasos, puntos, pestañas, desplegables). Aquí se transcribe el texto disponible; lo que no llegó en la copia está indicado donde corresponde. Los errores evidentes del original se corrigen con una nota breve.

## Introducción

La lección se divide en dos secciones sobre gestión de secretos y de la nube con Ansible: cómo usar **Ansible Vault** y algunas buenas prácticas, y cómo usar Ansible para crear y gestionar una infraestructura simple de **AWS EC2**.

## Gestión de secretos con Ansible Vault

Ansible Vault es una funcionalidad que permite a los usuarios de proyectos Ansible **cifrar valores y estructuras de datos**. Sirve para proteger cualquier dato sensible necesario para ejecutar los plays pero que no debe ser visible públicamente, como contraseñas o claves privadas.

Como Ansible se usa para automatizar, es muy probable que los playbooks contengan credenciales, certificados SSL u otros datos sensibles. Guardarlos en texto plano es mala idea: un commit equivocado a GitHub o el robo de un portátil puede causar una gran pérdida a una organización. Ahí entra Ansible Vault: permite tener infraestructura como código sin comprometer la seguridad.

Ejemplo: un playbook que aprovisiona una instancia EC2 en AWS necesita el *access key ID* y la *secret key*. No se comparten con otros por motivos obvios. ¿Cómo mantenerlas sin exponer? Hay dos formas: **cifrar esas dos variables e incrustarlas en el playbook, o cifrar el playbook entero**.

Es solo uno de los escenarios de uso. Se pueden cifrar archivos completos o solo algunas variables que contengan datos sensibles, y Ansible los descifra automáticamente en tiempo de ejecución. Así se pueden subir esos valores a GitHub con seguridad.

### Crear un archivo cifrado

Se usa `ansible-vault create` con el nombre del archivo. Pide crear una contraseña y confirmarla reescribiéndola. Una vez confirmada se crea el archivo y se abre una ventana de edición (por defecto el editor de Ansible Vault es `vi`). Ahí se agrega un secreto para la nueva variable `vault_learn_password`. Si se intenta ver el contenido del archivo creado, se verá que está cifrado. *(Los comandos y capturas de este paso no llegaron en la copia.)*

### Usar Vault en playbooks

La **buena práctica** es cifrar solo los datos sensibles. Vault permite cifrar variables concretas con el comando `ansible-vault encrypt_string` e insertar el dato cifrado donde se necesite *(el curso muestra cinco pasos interactivos; solo llegó el ejemplo de cifrado de una variable)*.

**Cifrar una variable:**

```
> ansible-vault encrypt_string "secret123" --name vault_test_password
New Vault password: 
Confirm New Vault password: 
vault_test_password: !vault |
          $ANSIBLE_VAULT;1.1;AES256
          65303231363732656433313063613063383565316139353933356331623665313433333537313964
          6339616364616164316364643539326564303135656237640a643162323663326633636630343065
          34633366653566393637336565333961666437376431623964373834646563383265366533333461
          6562366534663336610a336564356433633131646361306462393033643733633434366261643230
          3731
Encryption successful    

```

Otro enfoque es usar un **archivo vault dedicado y cifrado** y cargarlo en el playbook. En el ejemplo, el archivo cifrado `vault.yml` se carga como archivo de variables *(los pasos interactivos no llegaron; sí el playbook)*:

```
- name: VAULT DEMO
  hosts: localhost
  gather_facts: no

  vars_files:
    - vault.yml

  tasks:
    - name: Print Secret 3
      debug:
        msg:
          - "vault_password_3: {{ vault_password_3 }}"

    - name: Print Vault Secrets
      debug:
        msg:
          - "{{ item }}: {{ query('vars', item)|first }}"
      loop: "{{ query('varnames', 'vault_password_.+$') }}"

```

### Archivo de contraseña (*password file*)

Pedir la contraseña cada vez molesta y le quita sentido a la automatización. Ansible tiene la función *password file*: un archivo que contiene la contraseña, que se pasa en tiempo de ejecución para automatizar.

```
$ ansible-playbook playbook-vault-demo-2.yml --vault-password-file vaul_pass.txt
```

> El nombre del archivo en el original aparece como `vaul_pass.txt` (probable errata de `vault_pass.txt`).

También se puede fijar la ruta del archivo de contraseña en `ansible.cfg`, pero **hay que añadir ese archivo a `.gitignore`**:

```
[defaults]
### Ansible Vault
vault_password_file = .vault-pass

```

### Vault ID

Un **Vault ID** es una forma de dar un identificador a una contraseña de vault concreta. Permite cifrar distintos archivos con distintas contraseñas y referenciarlos dentro de un playbook. Si se ejecuta un playbook que usa varios archivos cifrados con contraseñas distintas, se usa Vault ID:

```
$ ansible-playbook --vault-id vault-pass1 --vault-id vault-pass2 filename.yml
```

Más detalles en la [documentación de Vault](https://docs.ansible.com/ansible/latest/user_guide/vault.html).

## Aprovisionar instancias EC2 con Ansible

Aquí se explora cómo usar Ansible para crear instancias EC2 en AWS y trabajar con ellas. Estas operaciones pueden automatizarse por completo. Se omiten los pasos de configuración del acceso a AWS porque se cubrieron en las lecciones de AWS.

Ansible soporta cientos de módulos para gestionar infraestructura cloud:

- [Amazon.AWS](https://docs.ansible.com/ansible/latest/collections/amazon/aws/index.html#plugins-in-amazon-aws)
- [community.aws](https://docs.ansible.com/ansible/latest/collections/index_module.html#community-aws)
- [Azure.Azcollection](https://docs.ansible.com/ansible/latest/collections/index_module.html#azure-azcollection)
- [Google.Cloud](https://docs.ansible.com/ansible/latest/collections/google/cloud/index.html#plugins-in-google-cloud)

Se aplica lo aprendido: **`group_vars`** para definir variables, **roles** para código reutilizable y un **playbook** que combina variables y roles para gestionar la infraestructura simple.

### 1. Crear una VPC

Para gestionar una VPC se usa el módulo `ec2_vpc_net`. En este ejemplo no se usa la VPC por defecto de AWS: se crea una nueva con Ansible. *(El paso a paso con la tarea del rol no llegó en la copia.)* Variables necesarias antes de crearla:

```
aws_region: us-east-1
aws_profile: sv-aws-ansible
aws_workshop_destroy: False

aws_tags_default:
  Owner: "EPAM MsDP"
  Email: "notify@example.com"
  Purpose: "Ansible Workshop"

aws_vpc_name: vpc-ansible-workshop
aws_vpc_cidr_block: 10.0.1.0/24

```

Se definen: la región donde se construye la infraestructura, el nombre del perfil de AWS CLI del que se toman las credenciales, los tags por defecto para los recursos, el nombre de la VPC y su bloque CIDR. Además se añade la variable especial `aws_workshop_destroy` para **eliminar fácilmente** los recursos creados.

Más detalles del módulo en la [documentación](https://docs.ansible.com/ansible/latest/collections/amazon/aws/ec2_vpc_net_info_module.html#ansible-collections-amazon-aws-ec2-vpc-net-info-module).

### 2. Crear una subred de la VPC

El módulo `ec2_vpc_subnet` gestiona subredes en VPCs de AWS. *(Los cinco pasos con la tarea no llegaron.)* Se añade una variable a `group_vars` para definir el tag de nombre:

```
aws_vpc_subnet_tags:
  Name: "subnet-ansible-workshop"

```

[Documentación del módulo](https://docs.ansible.com/ansible/latest/collections/amazon/aws/ec2_vpc_subnet_module.html#ansible-collections-amazon-aws-ec2-vpc-subnet-module).

### 3. Crear un Internet Gateway

Para que la VPC se comunique con Internet hace falta un Internet Gateway, que se gestiona con el módulo `ec2_vpc_igw`. *(Los cinco pasos con la tarea no llegaron.)* Variable para el tag de nombre:

```
aws_vpc_igw_tags:
  Name: "igw-ansible-workshop"

```

[Documentación del módulo](https://docs.ansible.com/ansible/latest/collections/amazon/aws/ec2_vpc_igw_module.html#ansible-collections-amazon-aws-ec2-vpc-igw-module).

### 4. Resumen de la automatización de la VPC

Se repasan todas las tareas y variables usadas para gestionar la VPC, repartiendo las variables en archivos distintos para mantenerlas fácilmente (pestañas "Variables" y "Roles").

**Variables**

`group_vars/all/aws-default.yml`

```
aws_region: us-east-1
aws_profile: sv-aws-ansible
aws_workshop_destroy: False

aws_tags_default:
  Owner: "EPAM MsDP"
  Email: "notify@example.com"
  Purpose: "Ansible Workshop"

```

`group_vars/all/aws-vpc.yml`

```
aws_vpc_name: vpc-ansible-workshop
aws_vpc_cidr_block: 10.0.1.0/24
aws_vpc_subnet_tags:
  Name: "subnet-ansible-workshop"
aws_vpc_igw_tags:
  Name: "igw-ansible-workshop"

```

**Roles** *(solo llegó el rol de destrucción; los roles de creación no llegaron)*

Estado actual del rol `aws-destroy`:

```
- name: Destroy AWS Workshop
  block:

    - name: Gather VPC Info
      ec2_vpc_net_info:
        filters:
          "tag:Name": "{{ aws_vpc_name }}"
      register: aws_vpc_info

    - name: Remove a VPC Internet Gateway
      ec2_vpc_igw:
        vpc_id: "{{ aws_vpc_info.vpcs.0.id }}"
        state: absent

    - name: Remove a VPC Subnet
      ec2_vpc_subnet:
        state: absent
        vpc_id: "{{ aws_vpc_info.vpcs.0.id }}"
        cidr: "{{ aws_vpc_cidr_block }}"

    - name: Remove a VPC
      ec2_vpc_net:
        name: "{{ aws_vpc_name }}"
        cidr_block: "{{ aws_vpc_cidr_block }}"
        state: absent

  when: aws_workshop_destroy|bool

```

Se usa el **orden inverso** para destruir la VPC porque no se puede borrar un recurso del que dependen otros. Ejemplo de error al intentar borrar una VPC que aún tiene una subred asociada:

```
TASK [aws-vpc-destroy : Remove a VPC] **************************************************************************************************************
An exception occurred during task execution. To see the full traceback, use -vvv. The error was: botocore.exceptions.ClientError: An error occurred (DependencyViolation) when calling the DeleteVpc operation: The vpc 'vpc-0fa876327be1ac5c4' has dependencies and cannot be deleted.
fatal: [localhost]: FAILED! => changed=false 
  boto3_version: 1.17.78
  botocore_version: 1.20.78
  error:
    code: DependencyViolation
    message: The vpc 'vpc-0fa876327be1ac5c4' has dependencies and cannot be deleted.
  msg: 'Failed to delete VPC vpc-0fa876327be1ac5c4 You may want to use the ec2_vpc_subnet, ec2_vpc_igw, and/or ec2_vpc_route_table modules to ensure the other components are absent.: An error occurred (DependencyViolation) when calling the DeleteVpc operation: The vpc ''vpc-0fa876327be1ac5c4'' has dependencies and cannot be deleted.'
  response_metadata:
    http_headers:
      cache-control: no-cache, no-store
      connection: close
      content-type: text/xml;charset=UTF-8
      date: Wed, 04 Aug 2021 15:43:06 GMT
      server: AmazonEC2
      strict-transport-security: max-age=31536000; includeSubDomains
      transfer-encoding: chunked
      vary: accept-encoding
      x-amzn-requestid: a2430756-72fe-4915-ad7e-43a4967dfdfb
    http_status_code: 400
    request_id: a2430756-72fe-4915-ad7e-43a4967dfdfb
    retry_attempts: 0

```

### 5. Crear un par de claves EC2 (*Key Pair*)

Un par de claves (pública y privada) es un conjunto de credenciales de seguridad para demostrar la identidad al conectarse a una instancia EC2. Amazon EC2 guarda la clave pública en la instancia y el usuario guarda la clave privada. En instancias Linux, la clave privada permite conectarse por SSH. **Quien posea la clave privada puede conectarse a las instancias, así que debe guardarse en un lugar seguro.** *(Los tres pasos con la tarea no llegaron.)*

Se crea un nuevo archivo de variables para todos los hosts en `group_vars`, con el material de la clave (equivale a la clave pública SSH) y el nombre de la clave:

```
aws_ec2_key_material: "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDeCpQao/wZJ8AJZSw+yZX3CDOzqBEN3gSHykAfylcO9tEcdjrTmwLF2oKjdengsSHEMe3l/HXa9uMBl+3D7r6E4brTPC4lULRnNwOJB/Eg1RxkXHr"
aws_ec2_key_name: "key-ansible-workshop"

```

[Documentación del módulo `ec2_key`](https://docs.ansible.com/ansible/latest/collections/amazon/aws/ec2_key_module.html#ansible-collections-amazon-aws-ec2-key-module).

### 6. Definir una AMI

Se busca el ID de la AMI más reciente de Amazon Linux con el módulo `ec2_ami_info` (filtra AMIs y recolecta facts). Para ordenar las AMIs y quedarse con la última se usan los filtros Jinja **`sort`** y **`last`**. *(El paso a paso no llegó.)*

El texto original indica "añadir una variable para definir un filtro de búsqueda de AMIs", pero el bloque que muestra a continuación es la tarea de creación del par de claves, no la variable del filtro:

```
- name: Create an EC2 Key Pair
  ec2_key:
    name: "{{ aws_ec2_key_name }}"
    key_material: "{{ aws_ec2_key_material }}"

```

> Probable error de copia del material: el contenido del filtro de AMI no está disponible. Lo que sí está en el texto: se usa `ec2_ami_info` + `sort` + `last`.

Más información: [módulo `ec2_ami_info`](https://docs.ansible.com/ansible/latest/collections/amazon/aws/ec2_ami_info_module.html#ansible-collections-amazon-aws-ec2-ami-info-module) y [manipulación de datos complejos con filtros](https://docs.ansible.com/ansible/latest/user_guide/complex_data_manipulation.html).

### 7. Crear un Security Group

Hace falta un security group para crear la instancia EC2. Se podría usar el `default`, pero se revisa un ejemplo simple de cómo Ansible gestiona un security group: se usa el módulo `ec2_group` para gestionar el grupo y `ec2_group_info` para recolectar facts de todos los grupos de una VPC. También se usa otro filtro Jinja2, **`selectattr`**, para excluir el grupo `default`, que no se puede borrar. *(El paso a paso no llegó.)*

Variables para el nuevo security group:

```
aws_ec2_sg_default_name: "default-ansible-workshop"
aws_ec2_sg_default_description: "Ansible Workshop Default SG"
aws_ec2_sg_default_tags:
  Name: "sg-default-ansible-workshop"
aws_ec2_sg_default_rules:
  - proto: "tcp"
    ports:
      - 22
    cidr_ip:
      - 0.0.0.0/0
    rule_desc: "Allow SSH Connetions"
  - proto: "tcp"
    ports:
      - 80
      - 443
    cidr_ip:
      - 10.0.1.0/24
    rule_desc: "Allow HTTP, HTTPS Connetions"

```

Más información: [`ec2_group`](https://docs.ansible.com/ansible/latest/collections/amazon/aws/ec2_vpc_net_module.html#ansible-collections-amazon-aws-ec2-vpc-net-module) (el enlace original apunta a la página de `ec2_vpc_net`) y [`ec2_group_info`](https://docs.ansible.com/ansible/latest/collections/amazon/aws/ec2_security_group_info_module.html#ansible-collections-amazon-aws-ec2-security-group-info-module).

### 8. Crear una instancia EC2

El paso final es crear la instancia EC2. El texto indica que se usa "el módulo `ec2`" para gestionar instancias (el enlace de documentación apunta a `ec2_instance_info`). *(El paso a paso no llegó.)* Primero se definen las variables necesarias y se crea una instancia `t2.micro` con **dos volúmenes adicionales**:

```
aws_ec2_instance_type: "t2.micro"
aws_ec2_instance_count: 1
aws_ec2_instance_public_ip: yes
aws_ec2_instance_wait: yes
aws_ec2_instance_wait_timeout: 500
aws_ec2_instance_volumes:
  - device_name: /dev/sdb
    volume_type: gp3
    volume_size: 10
    delete_on_termination: true
  - device_name: /dev/sdc
    volume_type: gp3
    volume_size: 20
    delete_on_termination: true

```

[Documentación del módulo](https://docs.ansible.com/ansible/latest/collections/amazon/aws/ec2_instance_info_module.html).

En el ejemplo se usó `loop_control` con `label` para controlar la salida. La etiqueta (*label*) reduce mucha información de la salida y deja solo la útil. *(Los desplegables "Ejemplo sin `loop_control`" y "Ejemplo con `loop_control`" no llegaron.)*

El playbook final de la lección está en: [svergun/ansible-workshop (carpeta `aws`)](https://github.com/svergun/ansible-workshop/tree/master/aws).

## Resumen de la lección

Se aprendió sobre **Ansible Vault**, una herramienta para cifrar datos sensibles, y se exploró el uso de Ansible para crear y gestionar una infraestructura simple de AWS EC2.

## Quiz de la lección

Preguntas para comprobar la comprensión de los conceptos clave. Es un quiz calificado (3 puntos); el resultado cuenta en la nota acumulada del módulo de Ansible (se necesita al menos 70 % acumulado). Hay dos intentos.

> Las respuestas no vienen en el material. Las marcadas como "deducida del texto" salen de lo explicado en la lección; la 1 es una estimación y **no está confirmada por la plataforma**.

**1. Elige las opciones correctas (puede haber más de una). Ansible Vault permite:**

- Crear un archivo con datos secretos
- Copiar un archivo con datos secretos
- Editar un archivo con datos secretos
- Reemitir y cambiar claves
- Crear claves
- Cifrar archivos existentes con variables
- Ver y leer los datos de su interior
- Cifrar una variable dentro de un archivo si hace falta

*Respuesta estimada:* crear (`ansible-vault create`), editar (`edit`), reemitir/cambiar claves (`rekey`), cifrar archivos existentes (`encrypt`), ver (`view`) y cifrar una sola variable (`encrypt_string`). No son operaciones de Vault: *copiar* un archivo con secretos y *crear claves* (las claves SSH/EC2 no se generan con Vault).

**2. Si hay que recorrer una salida enorme de Ansible, ¿qué ayuda a recortarla?**

- `loop_label`
- `loop_control with label`
- `loop_control with filters`
- `loop_filters`

*Respuesta (deducida del texto):* **`loop_control with label`**, como se explica al final de la sección EC2.

**3. Si hay que combinar tags de varias variables, ¿qué ayuda?**

- Módulo `merge` de Ansible
- Plugin `append` de Jinja2
- Plugin `combine` de Jinja2
- Es imposible combinar más de dos variables
- Solo se puede usar una variable para etiquetar recursos de AWS

*Respuesta estimada:* **`combine`** (filtro de Jinja2 para fusionar diccionarios, p. ej. `aws_tags_default | combine(aws_vpc_subnet_tags)`), coherente con tener `aws_tags_default` y `Name` en variables separadas. Este punto no se explica explícitamente en el texto de la lección.
