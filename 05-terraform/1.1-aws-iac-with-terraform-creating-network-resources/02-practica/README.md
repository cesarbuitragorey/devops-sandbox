# Práctica — Task 1: AWS IaC with Terraform: Creating Network Resources

## Enunciado de la tarea

### Task 1. AWS IaC with Terraform: Creating Network Resources

#### The Goal of the Task

To create a foundational network stack for virtual infrastructure in AWS using Terraform. This involves setting up a customized Virtual Private Cloud (VPC), an internet gateway, public subnets across multiple availability zones, and a routing table to manage traffic flow.

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
- Public subnets: subnets that provide internet access through an Internet Gateway within the VPC.
- Internet Gateway: a high-availability, fully managed, horizontal scaling gateway that provides internet access for resources in public subnets.
- Route table: a set of routing rules that controls traffic inside the VPC and to the internet for resources in public subnets.
- Local files:
  - `main.tf`: defines the AWS provider configuration
  - `variables.tf`: defines input variables used in the Terraform configuration
  - `vpc.tf`: defines the VPC, public subnets, Internet Gateway, and route table
  - `versions.tf`: defines the required Terraform and provider versions
  - `outputs.tf`: defines output values
  - `terraform.tfvars`: stores non-sensitive variable values

#### Objectives

1. Create the following files: `main.tf`, `variables.tf`, `vpc.tf`, `versions.tf`, `outputs.tf`, and `terraform.tfvars`.
2. In `main.tf`, define the AWS provider. Do not configure a backend. Terraform will use the local backend by default.
3. In `versions.tf`, define the required Terraform and provider versions.
4. In `variables.tf`, define the variables that will be used in `vpc.tf`.
5. In `vpc.tf`, create a VPC named `cmtr-iacp1ebx-01-vpc` with the CIDR block `10.10.0.0/16`.
6. In `vpc.tf`, create three public subnets in different Availability Zones:
   - `cmtr-iacp1ebx-01-subnet-public-a` in `eu-west-1a` with CIDR block `10.10.1.0/24`
   - `cmtr-iacp1ebx-01-subnet-public-b` in `eu-west-1b` with CIDR block `10.10.3.0/24`
   - `cmtr-iacp1ebx-01-subnet-public-c` in `eu-west-1c` with CIDR block `10.10.5.0/24`
7. Create an Internet Gateway named `cmtr-iacp1ebx-01-igw` and attach it to the VPC.
8. Create a route table named `cmtr-iacp1ebx-01-rt` and associate it with all public subnets so outbound internet traffic can pass through the Internet Gateway.
9. Put all non-sensitive input values into `terraform.tfvars`.
10. Run the Terraform workflow commands:
    - `terraform init` to initialize the working directory and initialize the local backend
    - `terraform fmt` to format your code
    - `terraform validate` to ensure configurations are correct
    - `terraform plan` to preview infrastructure changes
    - `terraform apply` to apply the changes
11. Verify that all created resources are connected correctly.

#### Verification

1. Confirm that all required files exist: `main.tf`, `variables.tf`, `vpc.tf`, `versions.tf`, `outputs.tf`, and `terraform.tfvars`.
2. In the AWS Console, open VPC and verify that the following resources were created correctly: `VPC`, `public subnets`, `Internet Gateway`, `route table`.
3. Verify that each subnet is associated with the correct route table.
4. Verify that the route table contains a route that sends internet-bound traffic through the Internet Gateway.

Note: Before running task verification:
- Push or update your Terraform configuration in your Git repository.
- Delete the AWS resources you created during the task by running `terraform destroy`.

To pass verification, your repository must contain the final Terraform code, but the deployed resources must already be removed.

**Región:** `eu-west-1` — Cuenta `148761676904`

**Entorno real usado:** código Terraform en este mismo directorio (`02-practica`), corrido localmente vía CLI (Git Bash) con las credenciales temporales de la task.

---

## Movimiento 1 — Instalación de Terraform

Terraform no estaba instalado en la máquina local. Se instaló vía `winget`:

```bash
winget install Hashicorp.Terraform
```

`winget` instaló el binario en `%LOCALAPPDATA%\Microsoft\WinGet\Packages\Hashicorp.Terraform_Microsoft.Winget.Source_8wekyb3d8bbwe\` pero no lo agregó al `PATH` de Git Bash automáticamente, así que hubo que agregarlo a mano en cada sesión de terminal:

```bash
export PATH="$PATH:/c/Users/zexar/AppData/Local/Microsoft/WinGet/Packages/Hashicorp.Terraform_Microsoft.Winget.Source_8wekyb3d8bbwe"
terraform -version
```

## Movimiento 2 — Flujo local de Terraform

Con las credenciales temporales de la task exportadas (`AWS_REGION`, `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_SESSION_TOKEN`):

```bash
cd "05-terraform/1.1-aws-iac-with-terraform-creating-network-resources/02-practica"

terraform init
terraform fmt -check
terraform validate
terraform plan
terraform apply -auto-approve
```

`apply` creó los 9 recursos esperados (VPC, 3 subnets, IGW, route table, 3 route table associations) sin errores. Tras confirmar los outputs (`vpc_id`, `public_subnet_ids`, `internet_gateway_id`, `route_table_id`), se destruyó todo localmente — la plataforma redespliega desde cero al verificar, así que dejar infraestructura de prueba viva habría chocado (mismos nombres/CIDRs) con la que crea el verificador:

```bash
terraform destroy -auto-approve
```

## Movimiento 3 — Push del código al repositorio

El código (`main.tf`, `variables.tf`, `vpc.tf`, `versions.tf`, `outputs.tf`, `terraform.tfvars`, `.gitignore`, `.terraform.lock.hcl`) se subió al repo de documentación `devops-sandbox`, reutilizándolo también como repo fuente para la verificación de la plataforma (en vez de crear un repo dedicado).

## Movimiento 4 — Verificación en la plataforma

El formulario de verificación de la task pide 3 datos:

- **Repository HTTPS URL with embedded token:**
  ```
  https://<usuario-github>:<personal-access-token>@github.com/cesarbuitragorey/devops-sandbox.git
  ```
  Se generó un *classic* Personal Access Token en GitHub (`github.com/settings/tokens/new`) con scope `repo`, y se embebió en la URL siguiendo el formato pedido por el enunciado (`https://<token-name_or_username>:<token>@<git-host>/<owner>/<repo>.git`).

- **Repository branch:**
  ```
  main
  ```

- **Repository folder:**
  ```
  05-terraform/1.1-aws-iac-with-terraform-creating-network-resources/02-practica
  ```
  Como el repo se reutiliza para toda la documentación del bootcamp (no es un repo dedicado a esta task), este campo le indica al verificador en qué subcarpeta específica están los 6 archivos `.tf`/`.tfvars` — sin este dato, el verificador buscaría en la raíz del repo y no los encontraría.

Al correr la verificación, la plataforma clonó el repo, corrió su propio `init`/`fmt`/`validate`/`plan`/`apply` dentro de esa carpeta, y validó los recursos reales contra la API de AWS (VPC, subnets, IGW, route table) — ver [03-resultados](../03-resultados/README.md) para el detalle de los 17 checks.

## Movimiento 5 — Limpieza

Tras el resultado exitoso, se usó el botón **"Destroy Resources"** de la plataforma para eliminar la infraestructura que ella misma desplegó durante la verificación.
