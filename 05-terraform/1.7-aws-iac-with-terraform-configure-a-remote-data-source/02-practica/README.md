# Práctica — Task 1.7: AWS IaC with Terraform: Configure a Remote Data Source

## Enunciado de la tarea

### AWS IaC with Terraform: Configure a Remote Data Source

#### The Goal of the Task

To learn how to use the Terraform `terraform_remote_state` data source to read outputs from an existing infrastructure. The task involves connecting to a pre-created Landing Zone stored in an S3 remote state file and creating an EC2 instance by reusing the existing VPC, subnet, and security group.

By the end of the task, you will have a working Terraform configuration that reads infrastructure details from a remote state file instead of hardcoding AWS resource IDs.

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

- A VPC with public and private subnets
- A security group for EC2 instances that allows SSH and HTTP access
- An S3 bucket that stores the Terraform state: `cmtr-iacp1ebx-tf-state-1790638679`
- A remote state file path: `infra.tfstate`

The Landing Zone infrastructure is read-only, so you must not modify it.

#### Task Resources

All region-specific resources are created in the `eu-west-1` region.

- AWS `aws_instance` resource: used to create and manage an EC2 instance
- Terraform `terraform_remote_state` data source: used to read outputs from an existing remote Terraform state
- Required EC2 tags:
  - `Terraform=true`
  - `Project=cmtr-iacp1ebx`
- Local files:
  - `variables.tf`: defines input variables used in your Terraform configuration
  - `terraform.tfvars`: stores variable values provided by the platform
  - `data.tf`: defines the remote state data source
  - `compute.tf`: defines the EC2 instance that uses remote state outputs
- Project ID: `cmtr-iacp1ebx`
- Available remote state outputs:
  - `vpc_id`: ID of the existing VPC
  - `public_subnet_id`: ID of the existing public subnet
  - `private_subnet_id`: ID of the existing private subnet
  - `security_group_id`: ID of the existing EC2 security group

#### Objectives

1. Create the following files in your Terraform project: `variables.tf`, `terraform.tfvars`, `data.tf`, and `compute.tf`.
2. In `variables.tf`, declare the following variables with correct descriptions and types:
   - `aws_region`: AWS region for the resources
   - `project_id`: project identifier used for tagging
   - `state_bucket`: S3 bucket name that stores the remote state
   - `state_key`: S3 key path to the remote state file
3. In `terraform.tfvars`, assign values to these variables by using the platform-provided values.
4. In `data.tf`, configure the `terraform_remote_state` data source:
   - Use the S3 backend
   - Use variables for the bucket, key, and region values
   - Do not hardcode any values
   - Name the data source `base_infra`
5. In `compute.tf`, create an `aws_instance` resource:
   - Place the instance in the public subnet
   - Use `data.terraform_remote_state.base_infra.outputs` to get the subnet and security group values
   - Do not hardcode any AWS resource IDs such as `vpc-...`, `subnet-...`, or `sg-...`
   - Add the required tags: `Terraform=true` and `Project=cmtr-iacp1ebx`
6. Format, validate, review, and apply your configuration:
   - Run `terraform fmt`
   - Run `terraform validate`
   - Run `terraform plan`
   - Run `terraform apply`

#### Verification

1. Confirm that all required files exist: `variables.tf`, `terraform.tfvars`, `data.tf`, and `compute.tf`.
2. Verify that `data.tf` has:
   - the `terraform_remote_state` data source uses the S3 backend;
   - the bucket, key, and region are taken from variables;
   - the data source name is `base_infra`.
3. Verify that `compute.tf` has correct subnet and security group from remote state.
4. Confirm that your instance has these tags:
   - `Terraform=true`
   - `Project=cmtr-iacp1ebx`
5. No AWS resource IDs are hardcoded.

Important:
- Do not hardcode any AWS resource IDs in your Terraform files.
- All infrastructure references must come from the remote state data source.
- Use variables for all remote state connection settings.

Note: Before running task verification:
- Push or update your Terraform configuration in your Git repository.
- Delete the AWS resources you created during the task by running `terraform destroy`.

To pass verification, your repository must contain the final Terraform code, but the deployed resources must already be removed.

**Región:** `eu-west-1` — Cuenta `585685714791`

**Entorno real usado:** código Terraform en este mismo directorio (`02-practica`), corrido localmente vía CLI (Git Bash).

---

## Movimiento 1 — Flujo local de Terraform

```bash
cd "05-terraform/1.7-aws-iac-with-terraform-configure-a-remote-data-source/02-practica"

terraform init
terraform fmt
terraform validate
terraform plan
terraform apply -auto-approve
```

`apply` creó 1 recurso sin errores (`aws_instance.this`), leyendo `subnet_id` y `vpc_security_group_ids` desde `data.terraform_remote_state.base_infra.outputs` — sin ningún ID de VPC/subnet/SG hardcodeado en el código.

## Movimiento 2 — Limpieza

```bash
terraform destroy -auto-approve
```

## Movimiento 3 — Primeros dos intentos de verificación fallidos por olvido de push

Se corrió la verificación en la plataforma dos veces seguidas con el mismo resultado ("Remote state data source is missing", "Required file variables.tf is missing") antes de haber comiteado y subido el código de esta task al repo — el `Repository folder` ya estaba bien puesto, pero el checker clonaba un repo que simplemente no tenía esos archivos todavía. `git status` confirmó que la carpeta `1.7-...` seguía sin trackear. Se corrigió con:

```bash
git add "05-terraform/1.7-aws-iac-with-terraform-configure-a-remote-data-source/"
git commit -m "Add Terraform code for task 1.7 (remote state data source)"
git push
```

## Movimiento 4 — Tercer intento: hardcoded value en la ruta del parámetro SSM

Con el código ya en el repo, la verificación avanzó mucho más (remote state reconocido, archivos encontrados), pero falló el check de "ausencia de hardcoded resources": el checker marcó como hardcodeada la ruta literal del parámetro SSM del AMI (`/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64`) usada en `compute.tf`. Se movió a una nueva variable `ami_ssm_parameter_name` (declarada en `variables.tf`, valor en `terraform.tfvars`), consistente con el resto de la configuración no sensible:

```bash
terraform fmt
terraform validate
terraform plan
```

Confirmado el plan limpio, se comiteó y subió el fix.

## Movimiento 5 — Verificación exitosa

- **Repository branch:** `main`
- **Repository folder:** `05-terraform/1.7-aws-iac-with-terraform-configure-a-remote-data-source/02-practica`
- **Repository HTTPS URL:** con PAT embebido.

15/15 checks pasados — ver [03-resultados](../03-resultados/README.md).

## Movimiento 6 — Limpieza final

Se usó el botón **"Destroy Resources"** de la plataforma.
