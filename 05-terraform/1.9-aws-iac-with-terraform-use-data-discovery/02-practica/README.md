# Práctica — Task 1.9: AWS IaC with Terraform: Use Data Discovery

## Enunciado de la tarea

### AWS IaC with Terraform: Use Data Discovery

#### The Goal of the Task

To learn how to use Terraform data sources to discover existing AWS infrastructure. Instead of reading values from a remote state file or hardcoding AWS resource IDs, you will query AWS resources using filters and tags.

The task involves finding an existing VPC, public subnet, security group, and the latest Amazon Linux 2023 AMI using Terraform data sources. Then, you will create an EC2 instance using only the values returned by the data sources.

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

The following infrastructure is already created for you in the `eu-west-1` region:

- VPC `cmtr-iacp1ebx-vpc` with public and private subnets
- Public subnet `cmtr-iacp1ebx-public-subnet-1` for the EC2 instance
- Security group `cmtr-iacp1ebx-sg` for the EC2 instance

You must discover these existing resources by using Terraform data sources, filters, and tags.

#### Task Resources

All region-specific resources are created in the `eu-west-1` region.

- AWS data sources: `aws_vpc`, `aws_subnet`, `aws_security_group`, `aws_ami`
- AWS `aws_instance` resource: used to create and manage an EC2 instance
- Local files:
  - `variables.tf` - defines the input variables used in the configuration
  - `terraform.tfvars` - stores the non-sensitive variable values provided by the platform
  - `data.tf` - contains the data sources used for resource discovery
  - `compute.tf` - defines the EC2 instance by using data source outputs
- Project identifier: `cmtr-iacp1ebx` used for tagging.

#### Objectives

1. Create the required Terraform files: `variables.tf`, `terraform.tfvars`, `data.tf`, and `compute.tf`.
2. In `variables.tf`, define the following variables with appropriate descriptions and types:
   - `aws_region` - the AWS region where resources are located
   - `project_id` - the project identifier used for tagging
   - `vpc_name` - the name of the VPC to discover
   - `public_subnet_name` - the name of the public subnet to discover
   - `security_group_name` - the name of the security group to discover
3. In `terraform.tfvars`, set the variable values by using the platform-provided parameters.
4. In `data.tf`, configure the following data sources using filters and tags to discover existing infrastructure:
   - `aws_vpc` to discover the VPC by its name tag
   - `aws_subnet` to discover the public subnet by its name tag
   - `aws_security_group` to discover the security group by its name tag
   - `aws_ami` to find the Amazon Linux 2023 AMI
5. In `compute.tf`, create an `aws_instance` resource named `cmtr-iacp1ebx-instance`. Configure it with the AMI, subnet, and security group values returned by your data sources. Make sure that no AWS resource IDs are hardcoded and all infrastructure references come from data sources.
6. Format and validate your configuration by running `terraform fmt`, `terraform validate`, `terraform plan`, and `terraform apply`.

#### Verification

The platform verification checks the following:

1. File structure: All required files `variables.tf`, `terraform.tfvars`, `data.tf`, and `compute.tf` are exist.
2. Data sources configuration: All required data sources are present and configured correctly.
3. Data sources usage: The Terraform configuration uses AWS data sources for resource discovery.
4. EC2 instance creation: The EC2 instance is created by using data source outputs.
5. Hardcoding check: No AWS resource IDs are hardcoded in the Terraform configuration.

Note: Before running task verification:
- Push or update your Terraform configuration in your Git repository.
- Delete the AWS resources you created during the task by running `terraform destroy`.

To pass verification, your repository must contain the final Terraform code, but the deployed resources must already be removed.

**Región:** `eu-west-1` — Cuenta `856238343966`

**Entorno real usado:** código Terraform en este mismo directorio (`02-practica`), corrido localmente vía CLI (Git Bash).

---

## Movimiento 1 — Flujo local de Terraform

```bash
cd "05-terraform/1.9-aws-iac-with-terraform-use-data-discovery/02-practica"

terraform init
terraform fmt
terraform validate
terraform plan
terraform apply -auto-approve
```

Los 4 data sources (`aws_vpc`, `aws_subnet`, `aws_security_group`, `aws_ami`) se resolvieron a la primera: VPC, subnet y SG por filtro `tag:Name`, y el AMI por `most_recent` + patrón de nombre. `apply` creó 1 recurso (`aws_instance.this`) usando solo valores de data sources, sin ningún ID hardcodeado.

## Movimiento 2 — Limpieza y push

```bash
terraform destroy -auto-approve
```

El código se comiteó y subió a `devops-sandbox` **antes** de correr la verificación.

## Movimiento 3 — Verificación en la plataforma

- **Repository branch:** `main`
- **Repository folder:** `05-terraform/1.9-aws-iac-with-terraform-use-data-discovery/02-practica`
- **Repository HTTPS URL:** con PAT embebido.

15/15 checks pasados en el primer intento — ver [03-resultados](../03-resultados/README.md).

## Movimiento 4 — Limpieza final

Se usó el botón **"Destroy Resources"** de la plataforma.
