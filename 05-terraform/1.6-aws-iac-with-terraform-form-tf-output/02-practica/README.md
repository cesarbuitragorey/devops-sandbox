# Práctica — Task 1.6: AWS IaC with Terraform: Form TF Output

## Enunciado de la tarea

### AWS IaC with Terraform: Form TF Output

#### The Goal of the Task

To create a basic AWS network infrastructure using Terraform. The task includes building a VPC, creating public subnets across different Availability Zones, attaching an Internet Gateway, and configuring a route table for internet access.

A key focus of the task is to create an `outputs.tf` file to display essential resource values, such as IDs and CIDR blocks, after the deployment is complete.

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

#### Task Resources

All region-specific resources are created in the `eu-west-1` region.

- AWS VPC: a logically isolated network in AWS cloud that provides control over your virtual networking environment.
- Public subnets: subnets that allow resources to access the internet through an Internet Gateway.
- Internet Gateway: a highly available, horizontally scaled gateway that provides internet access for resources in public subnets.
- Route table: a set of routing rules that controls traffic flow inside the VPC and to the internet.
- AWS Region (`eu-west-1`): a distinct geographic area with multiple Availability Zones for deploying resources.
- Local files:
  - `main.tf`: stores AWS provider configuration
  - `variables.tf`: declares input variables used in the Terraform configuration
  - `vpc.tf`: defines the VPC, subnets, Internet Gateway, and route table
  - `outputs.tf`: defines output values for the created resources

#### Objectives

1. Create the following Terraform files: `main.tf`, `variables.tf`, `vpc.tf`, and `outputs.tf`.
2. In `main.tf`, configure the AWS provider.
3. In `variables.tf`, declare all variables that are used in `vpc.tf`, ensure your configuration is modular and reusable.
4. In `vpc.tf`, create a VPC named `cmtr-iacp1ebx-01-vpc` with the CIDR block `10.10.0.0/16`.
5. In `vpc.tf`, create three public subnets in different Availability Zones:
   - `cmtr-iacp1ebx-01-subnet-public-a` in `eu-west-1a` with CIDR block `10.10.1.0/24`
   - `cmtr-iacp1ebx-01-subnet-public-b` in `eu-west-1b` with CIDR block `10.10.3.0/24`
   - `cmtr-iacp1ebx-01-subnet-public-c` in `eu-west-1c` with CIDR block `10.10.5.0/24`
6. Create an Internet Gateway named `cmtr-iacp1ebx-01-igw` and attach it to the VPC.
7. Create a route table named `cmtr-iacp1ebx-01-rt` and configure it to send internet-bound traffic through the Internet Gateway.
8. In `outputs.tf`, define the following outputs:
   - `vpc_id`: the ID of the VPC
   - `vpc_cidr`: the CIDR block of the VPC
   - `public_subnet_ids`: the IDs of all public subnets
   - `public_subnet_cidr_block`: the CIDR blocks of all public subnets
   - `public_subnet_availability_zone`: the Availability Zones of all public subnets
   - `internet_gateway_id`: the ID of the Internet Gateway
   - `routing_table_id`: the ID of the route table
9. Run the Terraform workflow commands:
   - `terraform init` to initialize the working directory and initialize the local backend
   - `terraform fmt` to format your code
   - `terraform validate` to ensure configurations are correct
   - `terraform plan` to preview infrastructure changes
   - `terraform apply` to deploy the EC2 instance
10. Check the console for the Terraform output and confirm that all required output values are displayed.

#### Verification

1. Confirm that all required files exist: `main.tf`, `variables.tf`, `vpc.tf`, and `outputs.tf`.
2. In `outputs.tf`, verify that all required outputs are defined with correct references to the created resources.
3. Open `outputs.tf` and verify that it contains these outputs:
   - `vpc_id`
   - `vpc_cidr`
   - `public_subnet_ids`
   - `public_subnet_cidr_block`
   - `public_subnet_availability_zone`
   - `internet_gateway_id`
   - `routing_table_id`
4. After `terraform apply`, verify that the output contains all required values.
5. In the AWS Console, verify that the following resources were created correctly: VPC, public subnets, Internet Gateway attached to the VPC, route table configured for internet access.
6. Make sure the resource names, CIDR blocks, and Availability Zones match the values provided in the task.

Note: Before running task verification:
- Push or update your Terraform configuration in your Git repository.
- Delete the AWS resources you created during the task by running `terraform destroy`.

To pass verification, your repository must contain the final Terraform code, but the deployed resources must already be removed.

**Región:** `eu-west-1` — Cuenta `913524900817`

**Entorno real usado:** código Terraform en este mismo directorio (`02-practica`), corrido localmente vía CLI (Git Bash).

---

## Movimiento 1 — Reutilizar el diseño de la task 1.1

Se copió el mismo patrón `for_each` sobre `map(object(...))` para los 3 subnets (evita hardcodear nombres de recurso), y se ajustó únicamente `outputs.tf` a los 7 nombres exactos pedidos por este enunciado.

## Movimiento 2 — Flujo local de Terraform

```bash
cd "05-terraform/1.6-aws-iac-with-terraform-form-tf-output/02-practica"

terraform init
terraform fmt
terraform validate
terraform plan
terraform apply -auto-approve
```

`apply` creó 9 recursos sin errores, con los 7 outputs mostrados correctamente en consola (objetivo 10 del enunciado).

## Movimiento 3 — Limpieza y push

```bash
terraform destroy -auto-approve
```

Código comiteado y subido a `devops-sandbox` **antes** de correr la verificación en la plataforma.

## Movimiento 4 — Verificación en la plataforma

- **Repository branch:** `main`
- **Repository folder:** `05-terraform/1.6-aws-iac-with-terraform-form-tf-output/02-practica`
- **Repository HTTPS URL:** con PAT embebido.

29/29 checks pasados en el primer intento — ver [03-resultados](../03-resultados/README.md).

## Movimiento 5 — Limpieza final

Se usó el botón **"Destroy Resources"** de la plataforma.
