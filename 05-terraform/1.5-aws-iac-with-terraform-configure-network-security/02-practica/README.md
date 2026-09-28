# Práctica — Task 1.5: AWS IaC with Terraform: Configure Network Security

## Enunciado de la tarea

### AWS IaC with Terraform: Configure Network Security

#### The Goal of the Task

To configure network security for AWS infrastructure using Terraform. The task involves creating security groups with specific ingress rules and controlling communication between public and private EC2 instances.

The primary objective is to utilize `source_security_group_id` references to allow secure traffic between instances while ensuring private resources are not directly exposed to the internet.

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

The following resources are already created for you:

- VPC `cmtr-iacp1ebx-vpc` (`vpc-08afc2a231d202fd0`) with CIDR block `10.0.0.0/16`
- Public subnet `cmtr-iacp1ebx-public-subnet` (`subnet-05d8445483206e41e`)
- Private subnet `cmtr-iacp1ebx-private-subnet` (`subnet-0838bed938d802aef`)
- Public EC2 instance `cmtr-iacp1ebx-public-instance` (`i-0a65b2611e2a908e6`) running Nginx on port `80`
- Private EC2 instance `cmtr-iacp1ebx-private-instance` (`i-03597e686899934f2`) running Nginx on port `8080`

#### Task Resources

All region-specific resources are created in the `eu-west-1` region.

- AWS `aws_security_group` resource: manages inbound and outbound traffic rules for EC2 instances
- AWS `aws_security_group_rule` resource: defines individual ingress or egress rules for a security group
- AWS `aws_network_interface_sg_attachment` resource: attaches security groups to existing network interfaces
- Required tag for each security group:
  - `Project=cmtr-iacp1ebx`
- Local files:
  - `variables.tf`: defines variables used in the Terraform configuration
  - `network_security.tf`: contains all network security resources
  - `terraform.tfvars`: stores variable values for your environment
- Project ID: `cmtr-iacp1ebx`

#### Objectives

1. Create the following files: `variables.tf`, `network_security.tf`, and `terraform.tfvars`.
2. In `variables.tf`, define the required variables with appropriate types and descriptions:
   - `allowed_ip_range`: a list of IP ranges allowed to access the infrastructure
   - all infrastructure ID variables provided by the platform, such as VPC ID and EC2 instance IDs
3. In `network_security.tf`, create the following security groups:
   - SSH Security Group name: `cmtr-iacp1ebx-ssh-sg` with the following ingress rules:
     - allow SSH (`22/tcp`) from `allowed_ip_range`
     - allow ICMP (all types) from `allowed_ip_range`
   - Public HTTP Security Group name: `cmtr-iacp1ebx-public-http-sg` with the following ingress rules:
     - allow HTTP (`80/tcp`) from `allowed_ip_range`
     - allow ICMP (all types) from `allowed_ip_range`
   - Private HTTP Security Group name: `cmtr-iacp1ebx-private-http-sg` with the following ingress rules:
     - allow HTTP (`8080/tcp`) from the Public HTTP Security Group
     - allow ICMP (all types) from the Public HTTP Security Group
     - use `source_security_group_id` instead of CIDR blocks for these rules
   - Ensure that all security groups are tagged with `Project=cmtr-iacp1ebx`
4. Attach the security groups to the existing instances by using `aws_network_interface_sg_attachment` resources:
   - Attach the SSH Security Group and Public HTTP Security Group to the public instance `cmtr-iacp1ebx-public-instance` (`i-0a65b2611e2a908e6`)
   - Attach the SSH Security Group and Private HTTP Security Group to the private instance `cmtr-iacp1ebx-private-instance` (`i-03597e686899934f2`)
5. In `terraform.tfvars`, set your IP ranges in the `allowed_ip_range` variable:
   - Use `allowed_ip_range = ["18.153.146.156/32", "YOUR_PUBLIC_IP/32"]`
   - Example: `allowed_ip_range = ["18.153.146.156/32", "203.0.113.25/32"]`
6. Format and validate your Terraform configuration:
   - Run `terraform fmt` to format your code
   - Run `terraform validate` to check for syntax errors and configuration issues
   - Run `terraform plan` to review the changes that will be applied to your infrastructure

#### Verification

1. Confirm that all required files exist: `variables.tf`, `network_security.tf`, and `terraform.tfvars`.
2. Verify that all three security groups were created with the correct names and tags.
3. Verify the security group rules:
   - the SSH Security Group has two ingress rules: SSH and ICMP
   - the Public HTTP Security Group has two ingress rules: HTTP and ICMP
   - the Private HTTP Security Group uses `source_security_group_id` references instead of CIDR blocks
4. Verify that the correct security groups are attached to each EC2 instance.
5. Confirm that the public instance serves the Nginx welcome page after the instance initialization is complete.

Important:
- The private instance must be accessible only from the public instance, not directly from the internet.
- Use `source_security_group_id` for the Private HTTP Security Group rules as a security best practice.
- Do not remove or modify the platform security group used for automated testing.

Note: Before running task verification:
- Push or update your Terraform configuration in your Git repository.
- Delete the AWS resources you created during the task by running `terraform destroy`.

To pass verification, your repository must contain the final Terraform code, but the deployed resources must already be removed.

**Región:** `eu-west-1` — Cuenta `891612557805`

**Entorno real usado:** código Terraform en este mismo directorio (`02-practica`), corrido localmente vía CLI (Git Bash).

---

## Movimiento 1 — Obtener la IP pública propia

```bash
curl -s https://checkip.amazonaws.com
```

Se agregó junto a la IP de ejemplo del enunciado en `allowed_ip_range` (`terraform.tfvars`).

## Movimiento 2 — Flujo local de Terraform

```bash
cd "05-terraform/1.5-aws-iac-with-terraform-configure-network-security/02-practica"

terraform init
terraform fmt
terraform validate
terraform plan
terraform apply -auto-approve
```

`apply` creó 13 recursos sin errores: 3 security groups, 6 reglas de ingress (SSH+ICMP, HTTP+ICMP, HTTP privado+ICMP vía `source_security_group_id`) y 4 `aws_network_interface_sg_attachment` (2 por instancia).

## Movimiento 3 — Verificar acceso HTTP al instance público

```bash
aws ec2 describe-instances --instance-ids i-0a65b2611e2a908e6 \
  --query 'Reservations[0].Instances[0].PublicIpAddress' --output text

curl -s http://<public-ip>
```

Confirmó la página de bienvenida de Nginx — objetivo 5 del enunciado cumplido antes de destruir.

## Movimiento 4 — Limpieza y push

```bash
terraform destroy -auto-approve
```

Código comiteado y subido a `devops-sandbox` **antes** de correr la verificación en la plataforma.

## Movimiento 5 — Verificación en la plataforma

- **Repository branch:** `main`
- **Repository folder:** `05-terraform/1.5-aws-iac-with-terraform-configure-network-security/02-practica`
- **Repository HTTPS URL:** con PAT embebido.

18/18 checks pasados en el primer intento — ver [03-resultados](../03-resultados/README.md).

## Movimiento 6 — Limpieza final

Se usó el botón **"Destroy Resources"** de la plataforma.
