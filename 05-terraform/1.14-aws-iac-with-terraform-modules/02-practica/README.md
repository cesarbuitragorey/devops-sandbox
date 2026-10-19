# Práctica — Task 1.14: AWS IaC with Terraform: Modules

## Enunciado de la tarea

### AWS IaC with Terraform: Modules

#### The Goal of the Task

To refactor an existing Terraform solution into reusable modules. Modular Terraform code improves readability, maintainability, and extensibility by grouping related resources into logical units.

The task involves creating separate modules for networking, network security, and application deployment behind an Application Load Balancer. After refactoring, the root configuration should utilize these modules to deploy the same infrastructure successfully.

#### Common Task Requirements

While working on the task, follow these requirements:

- Do not define a backend in your Terraform configuration. Terraform will use the local backend by default.
- Do not use the `local-exec` provisioner.
- Do not use the `prevent_destroy` lifecycle argument.
- Use `versions.tf` to define the required Terraform and AWS provider versions.
- Set Terraform `required_version` to `>= 1.5.7`.
- Define all variables only in `variables.tf`, and give each variable a valid description and type.
- Define resource names by using variables or generated dynamically/concatenated values, for example by using `locals` and Terraform functions.
- Avoid hardcoding resource names directly in resource blocks, and do not use the `default` argument for task variables.
- Put all non-sensitive input values in `terraform.tfvars`.
- Define outputs only in `outputs.tf`, and give each output a valid description.
- Keep your Terraform code clean and properly formatted. Run `terraform fmt` before committing your code to ensure it follows standard style conventions.

#### Check Results

Once you complete the task, enter your repository HTTPS URL with a Personal Access Token in the Repository HTTPS URL with embedded token field. If needed, provide any additional input parameters, then click the `Verification` button. During verification, the platform will automatically evaluate your solution and display the final result. A score of 100% means all checks passed successfully. If any checks fail, feedback will be shown so you can review and improve your solution.

Note: All previously created infrastructure will be redeployed from scratch during each new verification. This process can take some time, so please be patient.

After starting the task, you have 2.5 hours to complete verification. If verification is not completed within this time, all existing infrastructure will be destroyed and you will need to restart the task.

#### Pre-created Environment

The platform provides the task parameters that you must use in your Terraform configuration, including resource names, CIDR blocks, availability zones, and the platform public IP `18.153.146.156`.

You must create the AWS infrastructure yourself by using Terraform modules.

#### Task Resources

All region-specific resources are created in the `eu-west-1` region.

**Network Module Resources**

- VPC `cmtr-iacp1ebx-vpc` with CIDR block `10.10.0.0/16`
- Subnet `cmtr-iacp1ebx-subnet-public-a` in availability zone `eu-west-1a` with CIDR block `10.10.1.0/24`
- Subnet `cmtr-iacp1ebx-subnet-public-b` in availability zone `eu-west-1b` with CIDR block `10.10.3.0/24`
- Subnet `cmtr-iacp1ebx-subnet-public-c` in availability zone `eu-west-1c` with CIDR block `10.10.5.0/24`
- Internet Gateway `cmtr-iacp1ebx-igw` attached to the VPC `cmtr-iacp1ebx-vpc`
- Route table `cmtr-iacp1ebx-rt` that enables outbound internet access for the public subnets

**Network Security Module Resources**

- SSH security group `cmtr-iacp1ebx-ssh-sg` with ingress rule allowing SSH on port `22/tcp` from `"18.153.146.156/32"` and "YOUR_PUBLIC_IP/32"
- Public HTTP security group `cmtr-iacp1ebx-public-http-sg` with ingress rule allowing HTTP on port `80/tcp` from `"18.153.146.156/32"` and "YOUR_PUBLIC_IP/32"
- Private HTTP security group `cmtr-iacp1ebx-private-http-sg` with ingress rule allowing HTTP on port `80/tcp` from the public HTTP security group `cmtr-iacp1ebx-public-http-sg`

**Application Module Resources**

Use instance metadata in the launch template user data to display values similar to the following:

```bash
COMPUTE_MACHINE_UUID=$(cat /sys/devices/virtual/dmi/id/product_uuid | tr '[:upper:]' '[:lower:]')
TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
COMPUTE_INSTANCE_ID=$(curl -H "X-aws-ec2-metadata-token: ${TOKEN}" http://169.254.169.254/latest/meta-data/instance-id)
```

The generated web page should display a message similar to this:

```
This message was generated on instance {COMPUTE_INSTANCE_ID} with the following UUID {COMPUTE_MACHINE_UUID}
```

- Launch template `cmtr-iacp1ebx-template`
  - Instance type: `t3.micro`
  - Security groups: `cmtr-iacp1ebx-ssh-sg` and `cmtr-iacp1ebx-private-http-sg`
  - Network interface setting: `delete_on_termination = true`
  - Use `user data` to install a web server and display instance-specific content
- Auto Scaling group `cmtr-iacp1ebx-asg`
  - Desired capacity: `2`
  - Minimum size: `2`
  - Maximum size: `2`
  - Add a lifecycle block to ignore changes to `load_balancers` and `target_group_arns`
- Application Load Balancer `cmtr-iacp1ebx-lb`
  - HTTP listener on port `80`
  - Attached to the Auto Scaling group by using `aws_autoscaling_attachment`
  - Uses security group `cmtr-iacp1ebx-public-http-sg`

#### Objectives

1. Create a `modules` directory inside your project with the following structure:

   *(El bloque con el árbol de directorios llegó vacío en el enunciado copiado; la estructura usada está en la sección "Diseño" más abajo y coincide con lo que valida el check "Validating the Existence of Modules and Required Files".)*

2. In each module directory, create the following files:
   - `main.tf` for resource definitions
   - `variables.tf` for module input variables
   - `outputs.tf` for module outputs
3. In the `network` module, add the VPC, subnets, internet gateway, and routing resources.
4. Parameterize the network module by using variables for CIDR blocks, availability zones, and resource names.
5. Export the VPC ID and subnet IDs from the network module.
6. In the `network_security` module, add the security groups and security group rules.
7. Parameterize the network security module by using variables for the VPC ID and the allowed IP ranges.
8. In `terraform.tfvars`, set `allowed_ip_range = ["18.153.146.156/32", "YOUR_PUBLIC_IP/32"]`.
9. Export the security group IDs from the network security module.
10. In the `application` module, add the launch template, Auto Scaling group, load balancer, and related resources.
11. Parameterize the application module by using variables for subnet IDs, security group IDs, and instance settings.
12. Export the load balancer DNS name as an output.
13. Update the root configuration so that it uses the `network`, `network_security`, and `application` modules.
14. Validate and format both the root configuration and all modules.
15. Run `terraform plan` to confirm that the modular configuration is valid.

Use the following Terraform workflow:

*(El bloque con el workflow llegó vacío en el enunciado copiado; se usó el flujo estándar `terraform init`, `terraform fmt -recursive`, `terraform validate`, `terraform plan`, `terraform apply`.)*

Run formatting and validation for the root configuration and for each module as needed.

#### Verification

Use the following checks to verify that your solution is correct:

1. Confirm that the `modules/network`, `modules/network_security`, and `modules/application` directories exist and contain `main.tf`, `variables.tf`, and `outputs.tf`.
2. Verify that the root Terraform configuration uses all three modules successfully.
3. Run `terraform plan` after the configuration is ready and confirm that Terraform does not show unexpected changes.
4. Open the AWS Console and verify that the VPC, subnets, security groups, launch template, Auto Scaling group, and load balancer are created.
5. Confirm that the EC2 instances are running behind the Application Load Balancer.
6. Open the application through the load balancer DNS name and verify that the web server returns the expected instance-specific content.
7. Confirm that the modular refactor preserves the same application behavior after deployment.

Important:

- Do not leave resources only in the root configuration. The goal of this task is to move the logic into reusable modules.
- Make sure module inputs and outputs are used correctly so modules can pass values to one another through the root configuration.
- Replace `YOUR_PUBLIC_IP/32` with your actual public IP address in `terraform.tfvars`.

Note: Before running task verification:
- Push or update your Terraform configuration in your Git repository.
- Delete the AWS resources you created during the task by running `terraform destroy`.

To pass verification, your repository must contain the final Terraform code, but the deployed resources must already be removed.

**Región:** `eu-west-1` — Cuenta `842676000879`

**Entorno real usado:** código Terraform en este directorio (`02-practica`), corrido localmente vía CLI (Git Bash).

---

## Diseño

```
02-practica/
├── main.tf            # provider + llamadas a los 3 módulos
├── variables.tf
├── terraform.tfvars
├── outputs.tf
├── versions.tf
└── modules/
    ├── network/            (main.tf, variables.tf, outputs.tf)  VPC, subnets, IGW, route table
    ├── network_security/   (main.tf, variables.tf, outputs.tf)  3 security groups
    └── application/        (main.tf, variables.tf, outputs.tf)  launch template, ASG, ALB, target group, listener, attachment
```

- **Flujo de datos entre módulos** (siempre a través de la raíz): `network` exporta `vpc_id` y `public_subnet_ids`; `network_security` recibe `vpc_id` y exporta `ssh_sg_id`, `public_http_sg_id`, `private_http_sg_id`; `application` recibe subnets y SGs y exporta `lb_dns_name`.
- La raíz no declara recursos propios; todos los nombres, CIDRs, el patrón del AMI y los tamaños del ASG salen de `terraform.tfvars`. Las etiquetas (`Terraform=true`, `Project=cmtr-iacp1ebx`) viajan como un único mapa `common_tags`.
- `0.0.0.0/0` se pasa como variable (`internet_cidr`) para no dejar literales en los módulos (lección del checker de "hardcoded" de la task 1.7).
- **Reglas de egress explícitas**: Terraform elimina la regla de salida "allow all" por defecto de los security groups que crea. Sin ellas, las instancias no pueden hacer `dnf install httpd` y el ALB no puede alcanzar a las instancias. Cada SG declara su `egress` abierto.
- Mi IP pública (`190.255.115.133/32`, obtenida con `curl -s https://checkip.amazonaws.com`) va junto a la de la plataforma en `allowed_ip_range`.

## Movimiento 1 — Primer apply local (24 recursos) y prueba

```bash
terraform init
terraform fmt -recursive
terraform validate
terraform plan
terraform apply -auto-approve
```

Con la primera versión (reglas como recursos `aws_security_group_rule` separados) el `apply` creó 24 recursos. Con `curl` al DNS del ALB, 10 peticiones se repartieron 5/5 entre las dos instancias (cada una en una subnet distinta). Después `terraform destroy`.

## Movimiento 2 — Verificación: intentos y correcciones

1. **Intento 1 — falló el check 11** ("resource types permitidos en `network_security`"): `Unexpected resources found in Terraform plan: aws_security_group_rule`. El checker valida qué tipos de recurso puede crear cada módulo. Corrección: reglas **inline** (`ingress`/`egress` dentro de `aws_security_group`), de modo que el módulo solo crea `aws_security_group`. El plan pasó de 24 a 18 recursos con las mismas reglas efectivas.
2. **Intento 2 — pasaron los checks 1 al 25; falló el 26** (Load Balancing): `All responses came from the same UUID - Load balancing NOT working`. Mi página mostraba `Hello from instance <id> with private IP <ip>`, porque los bloques de código del enunciado (el formato del mensaje y los comandos de metadata) habían llegado vacíos al copiarlo. Con los bloques ya visibles el formato correcto era `This message was generated on instance … with the following UUID …`, con el UUID de la máquina tomado de `/sys/devices/virtual/dmi/id/product_uuid` en minúsculas. Se actualizó el `user_data` y, de paso, se acortó el health check del target group (intervalo 5 s, umbral 2) para que los targets queden sanos poco después de crearse el listener, en vez de ~90 s.
3. **Intentos 3 y 4 — el check 26 siguió fallando igual.** Un intento de `apply` local chocó con `Launch template name already in use` / `Target Group already exists` / `Load Balancer already exists`: los recursos del despliegue de la plataforma del intento 2 seguían vivos en la misma cuenta. Consultando el ALB de la plataforma (solo lectura) se vio que **seguía sirviendo el formato viejo** con las mismas dos instancias, mientras que su target group ya tenía el health check nuevo (intervalo 5): la plataforma había aplicado el código nuevo *encima* del despliegue existente. Un ASG no reemplaza instancias en marcha cuando cambia su launch template (`version = "$Latest"` solo afecta a las instancias nuevas). Se terminaron las 2 instancias con `aws autoscaling terminate-instance-in-auto-scaling-group --no-should-decrement-desired-capacity`; el ASG lanzó 2 nuevas con el template nuevo, y a los ~3 minutos 10 peticiones al ALB mostraron 2 UUID distintos alternando.
4. **Intento 5 — 26/26 checks aprobados.** En esta corrida la plataforma desplegó los 18 recursos desde cero (VPC y demás con IDs nuevos) y el check 26 devolvió `Unique UUIDs found - Load balancing is working`.

## Movimiento 3 — Limpieza local y final

El `terraform destroy` local eliminó los recursos creados en las pruebas (24 en la primera, 12 del stack parcial tras el choque de nombres). Al terminar se usó el botón **"Destroy Resources"** de la plataforma.
