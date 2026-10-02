# Práctica — Task 1.8: AWS IaC with Terraform: Configure Application Instances behind a Load Balancer

## Enunciado de la tarea

### AWS IaC with Terraform: Configure Application Instances behind a Load Balancer

#### The Goal of the Task

To deploy an application behind an Application Load Balancer using pre-created AWS resources. The task involves creating a Launch Template with a startup script, using it in an Auto Scaling Group, and configuring an Application Load Balancer to route HTTP traffic to EC2 instances.

The startup script must install and start a web server, retrieve instance metadata using IMDSv2, and generate a simple HTML page displaying the instance ID and private IP address. By the end of the task, you will have a fully functional load-balanced application deployment built with Terraform.

#### Common Task Requirements

- Do not define a backend in your Terraform configuration. Terraform will use the local backend by default.
- Do not use the `local-exec` provisioner.
- Do not use the `prevent_destroy` lifecycle attribute.
- Use `versions.tf` to define the required Terraform and provider versions.
- Set Terraform `required_version` to `>= 1.5.7`.
- Define all variables only in `variables.tf`, and make sure each variable has a valid description and type.
- Resource names provided in tasks should be defined via variables or generated dynamically/concatenated (e.g., in `locals` using Terraform functions). Avoid hardcoding resource names in resource definitions or using the `default` property for variables.
- Put all non-sensitive input values into `terraform.tfvars`.
- Define outputs only in `outputs.tf`, and make sure each output has a valid description.
- Keep your Terraform code clean and properly formatted. Use the `terraform fmt` command to format your code according to the standard style conventions.

#### Check Results

Once you complete the task, enter your repository HTTPS URL with a Personal Access Token in the Repository HTTPS URL with embedded token field. If needed, provide any additional input parameters, then click the `Verification` button. During verification, the platform will automatically evaluate your solution and display the final result. A score of 100% means all checks passed successfully. If any checks fail, feedback will be shown so you can review and improve your solution.

Note: All previously created infrastructure will be redeployed from scratch during each new verification. This process may take time, so please be patient.

After starting the task, you will have 2.5 hours to complete verification. If verification is not completed within this time frame, all existing infrastructure will be destroyed, and you will need to restart the task.

#### Pre-created Environment

The following resources are already deployed for you:

- VPC `cmtr-iacp1ebx-vpc` CIDR block
- Subnets in the VPC with the following CIDR blocks:
  - public subnet A: `10.0.1.0/24`
  - private subnet A: `10.0.2.0/24`
  - public subnet B: `10.0.3.0/24`
  - private subnet B: `10.0.4.0/24`
- Security groups:
  - `cmtr-iacp1ebx-ec2_sg`: allows SSH access to EC2 instances.
  - `cmtr-iacp1ebx-http_sg`: allows HTTP access to EC2 instances.
  - `cmtr-iacp1ebx-sglb`: allows HTTP access to the load balancer from the internet.
- IAM instance profile `cmtr-iacp1ebx-instance_profile` with the necessary permissions for EC2 instances to work with the AWS services used in this lab.
- Key pair `cmtr-iacp1ebx-keypair` for SSH access to EC2 instances.

#### Task Resources

All region-specific resources are created in the `eu-west-1` region.

- AWS Launch Template `cmtr-iacp1ebx-template`: defines how EC2 instances are launched.
- AWS Auto Scaling Group `cmtr-iacp1ebx-asg`: manages EC2 instances created from the Launch Template.
- AWS Application Load Balancer `cmtr-iacp1ebx-loadbalancer`: distributes HTTP traffic across the instances in the Auto Scaling Group.
- Related resources that you will also need to configure:
  - target group
  - listener
  - Auto Scaling attachment to the target group
- Local file:
  - `application.tf`: contains all Terraform resources for this task
- Required tags:
  - `Terraform=true`
  - `Project=cmtr-iacp1ebx`
- Amazon Machine Image (AMI): the template used to launch EC2 instances. You can use a data source to retrieve the AMI dynamically instead of hardcoding an AMI ID.

#### Objectives

1. Create the `application.tf` file and define all resources for this task in it.
2. Create a Launch Template named `cmtr-iacp1ebx-template` with the following settings:
   - instance type `t3.micro`
   - AMI `Amazon Linux 2023` (you may use a data source to get the AMI ID dynamically or use AMI Image ID available in the `eu-west-1` region)
   - security groups `cmtr-iacp1ebx-ec2_sg` and `cmtr-iacp1ebx-http_sg`
   - network interface setting `delete_on_termination = true`
   - key pair `cmtr-iacp1ebx-keypair`
   - IAM instance profile `cmtr-iacp1ebx-instance_profile`
   - `user_data` resource that contains the startup bash script
   - `metadata_options` configured with:
     - `http_endpoint = "enabled"`
     - `http_tokens = "optional"`
   - In the `user_data` startup script of the Launch Template, implement the following logic to run when the instance first starts:
     - update system packages
     - install the required packages for a basic web server, such as `httpd` and `jq`
     - enable the web server to start automatically and start it immediately
     - retrieve the instance ID and private IP address by using IMDSv2 and the `curl` command to access the instance metadata service
     - create the file `/var/www/html/index.html` with the following message that will display the instance ID and private IP address:

       *(El bloque con el texto exacto del mensaje llegó vacío en el enunciado copiado; ver la sección "Mensaje HTML" más abajo para lo que se implementó.)*

3. Create an Auto Scaling Group named `cmtr-iacp1ebx-asg` that uses the Launch Template with these settings:
   - desired capacity `2`
   - minimum size `1`
   - maximum size `2`
   - a lifecycle block that ignores changes to `load_balancers` and `target_group_arns`
4. Create an Application Load Balancer named `cmtr-iacp1ebx-loadbalancer` with these settings:
   - HTTP listener on port `80`
   - security group `cmtr-iacp1ebx-sglb`
   - configuration required to route traffic to the Auto Scaling Group instances
5. Attach the Auto Scaling Group to the load balancer target group by using `aws_autoscaling_attachment`.
6. Add the following tags to all created resources:
   - `Terraform=true`
   - `Project=cmtr-iacp1ebx`
7. Run the Terraform workflow commands:
   - `terraform init` to initialize the working directory and initialize the local backend
   - `terraform fmt` to format the Terraform configuration files
   - `terraform validate` to validate the configuration files
   - `terraform plan` to create an execution plan
   - `terraform apply` to apply the changes and create the resources in AWS.

#### Verification

1. In the AWS Console, verify that these resources were created successfully:
   - Launch Template `cmtr-iacp1ebx-template`
   - Auto Scaling Group `cmtr-iacp1ebx-asg`
   - Application Load Balancer `cmtr-iacp1ebx-loadbalancer`
2. Verify that the load balancer has a listener on port `80` and routes traffic to healthy instances.
3. Verify that the Auto Scaling Group launches EC2 instances from the Launch Template.
4. Verify that the startup script runs successfully and that each instance serves the generated HTML page.
5. Open the Application Load Balancer DNS name in a browser and confirm that the page shows the instance message with the instance ID and private IP address.
6. Confirm that all created resources have these tags:
   - `Terraform=true`
   - `Project=cmtr-iacp1ebx`

Note: Before running task verification:
- Push or update your Terraform configuration in your Git repository.
- Delete the AWS resources you created during the task by running `terraform destroy`.

To pass verification, your repository must contain the final Terraform code, but the deployed resources must already be removed.

**Región:** `eu-west-1` — Cuenta `692859931137`

**Entorno real usado:** código Terraform en este mismo directorio (`02-practica`), corrido localmente vía CLI (Git Bash).

---

## Mensaje HTML

El bloque de código con el texto exacto del mensaje no se transmitió en el enunciado copiado. El script de `user_data` implementado escribe en `/var/www/html/index.html`:

```html
<html><body><h1>Hello from instance $INSTANCE_ID with private IP $PRIVATE_IP</h1></body></html>
```

donde `INSTANCE_ID` y `PRIVATE_IP` se obtienen vía IMDSv2 (token con `PUT /latest/api/token`, luego `meta-data/instance-id` y `meta-data/local-ipv4`).

## Movimiento 1 — Flujo local de Terraform

```bash
cd "05-terraform/1.8-aws-iac-with-terraform-configure-application-instances-behind-a-load-balancer/02-practica"

terraform init
terraform fmt
terraform validate
terraform plan
terraform apply -auto-approve
```

`apply` creó 6 recursos sin errores: target group, launch template, ASG, ALB (~2 min, el más lento), listener y `aws_autoscaling_attachment`. VPC, subnets públicos, los 3 security groups, el AMI (vía SSM) se resolvieron con data sources; el instance profile y el key pair por nombre.

## Movimiento 2 — Prueba del balanceo

Con las instancias ya sanas (2-3 min tras el apply):

```bash
for i in 1 2 3 4 5; do curl -s http://$(terraform output -raw load_balancer_dns_name); echo; done
```

Las respuestas alternaron entre las dos instancias (una en cada subnet público: `10.0.1.x` y `10.0.3.x`), cada una mostrando su propio instance ID y IP privada — confirma el round-robin del ALB y que el script IMDSv2 corrió bien.

## Movimiento 3 — Limpieza y push

```bash
terraform destroy -auto-approve
```

El `destroy` tardó ~1 min en el ASG (termina sus instancias antes de borrarse). El código se comiteó y subió a `devops-sandbox` antes de verificar.

## Movimiento 4 — Verificación en la plataforma

- **Repository branch:** `main`
- **Repository folder:** `05-terraform/1.8-aws-iac-with-terraform-configure-application-instances-behind-a-load-balancer/02-practica`
- **Repository HTTPS URL:** con PAT embebido.

Resultado: ver [03-resultados](../03-resultados/README.md).

## Movimiento 5 — Limpieza final

Se usó el botón **"Destroy Resources"** de la plataforma.
