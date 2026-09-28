# Práctica — Task 1.2: AWS IaC with Terraform: Create Resources for SSH Authentication

## Enunciado de la tarea

### AWS IaC with Terraform: Create Resources for SSH Authentication

#### The Goal of the Task

To configure secure SSH access to an EC2 instance using Terraform. The task involves creating a custom SSH key pair, registering the public key in AWS, and launching an EC2 instance that uses this key for authentication. Additionally, Terraform data sources will be utilized to reference existing infrastructure created by the platform, avoiding redundant resource creation.

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

The following resources are already created for you in the `eu-west-1` region:

- VPC `cmtr-iacp1ebx-vpc`
- Public subnets inside the VPC with public IP auto-assignment enabled
- Security group `cmtr-iacp1ebx-sg` that allows SSH access

Use Terraform data sources to reference these resources instead of creating new ones.

#### Task Resources

All region-specific resources should be created in the `eu-west-1` region.

- SSH key pair: a pair of public and private keys used for secure SSH authentication
- AWS `aws_key_pair` resource: registers your public SSH key in AWS so that it can be used for secure access to EC2 instances
- AWS `aws_instance` resource: creates and manages an EC2 instance that will be accessed via SSH
- Terraform data sources: `aws_vpc`, `aws_subnet`, `aws_security_group`
- Local files:
  - `variables.tf`: defines variables used in the Terraform configuration
  - `ssh.tf`: defines the SSH key pair resource and related configuration
  - `ec2.tf`: defines the EC2 instance and its configuration
- Required tags for all created resources:
  - `Project=epam-tf-lab`
  - `ID=cmtr-iacp1ebx`

#### Objectives

1. Create the following files: `variables.tf`, `ssh.tf`, and `ec2.tf`.
2. Generate a custom SSH key pair.
3. In `variables.tf`, define an empty variable named `ssh_key` with the description `Provides custom public SSH key.`
4. In `ssh.tf`, create an `aws_key_pair` resource named `cmtr-iacp1ebx-keypair` and use the `ssh_key` variable as the source of the public key.
5. In `ec2.tf`, use the following Terraform data sources to reference existing infrastructure:
   - `aws_vpc`
   - `aws_subnet`
   - `aws_security_group`
6. In `ec2.tf`, create an `aws_instance` resource named `cmtr-iacp1ebx-ec2` and configure the EC2 instance with the following settings:
   - attach the `cmtr-iacp1ebx-keypair` key pair;
   - associate it with the security group `cmtr-iacp1ebx-sg`;
   - launch it in a public subnet;
   - map the instance to a public IP address for SSH access.
7. Add the following tags to all created resources:
   - `Project=epam-tf-lab`
   - `ID=cmtr-iacp1ebx`
8. Pass your public SSH key as an environment variable and do not store it in the repository:
   - Linux or macOS: `export TF_VAR_ssh_key="YOUR_PUBLIC_SSH_KEY_STRING"`
   - PowerShell: `$env:TF_VAR_ssh_key="YOUR_PUBLIC_SSH_KEY_STRING"`
9. Run the Terraform workflow commands:
   - `terraform init` to initialize the working directory and initialize the local backend
   - `terraform fmt` to format your code
   - `terraform validate` to validate the configuration
   - `terraform plan` to create an execution plan and review the planned changes
   - `terraform apply` to apply the changes and deploy the EC2 instance.
10. Connect to `cmtr-iacp1ebx-ec2` by using SSH and your local private key.

#### Verification

1. Confirm that all required files exist: `variables.tf`, `ssh.tf`, and `ec2.tf`.
2. Check the Terraform outputs from `terraform plan` and `terraform apply` to ensure there are no errors and all configurations have been applied correctly.
3. Verify that no public SSH key is hardcoded in any Terraform file.
4. In the AWS Console, verify that the key pair `cmtr-iacp1ebx-keypair` was created successfully.
5. Verify that the EC2 instance `cmtr-iacp1ebx-ec2` is running.
6. Verify that the instance has a public IP address.
7. Verify that the correct security group is attached to the instance.
8. Confirm that you can connect to the instance over SSH by using your local private key.
9. Verify that the required tags are applied to all created resources.

Note: Before running task verification:
- Push or update your Terraform configuration in your Git repository.
- Delete the AWS resources you created during the task by running `terraform destroy`.

To pass verification, your repository must contain the final Terraform code, but the deployed resources must already be removed.

**Región:** `eu-west-1` — Cuenta `762233765440`

**Entorno real usado:** código Terraform en este mismo directorio (`02-practica`), corrido localmente vía CLI (Git Bash).

---

## Movimiento 1 — Generar el par de llaves SSH

```bash
ssh-keygen -t ed25519 -f ~/.ssh/cmtr-iacp1ebx -C "cmtr-iacp1ebx" -N ""
```

## Movimiento 2 — Pasar la clave pública como variable de entorno (sin tocar el repo)

```bash
export TF_VAR_ssh_key="$(cat ~/.ssh/cmtr-iacp1ebx.pub)"
```

## Movimiento 3 — Flujo local de Terraform

Con las credenciales temporales de la task y `TF_VAR_ssh_key` exportados:

```bash
cd "05-terraform/1.2-aws-iac-with-terraform-create-resources-for-ssh-authentication/02-practica"

terraform init
terraform fmt -check
terraform validate
terraform plan
terraform apply -auto-approve
```

`apply` creó 2 recursos (`aws_key_pair.this`, `aws_instance.this`) sin errores, con output `instance_public_ip`.

## Movimiento 4 — Verificar el acceso SSH

```bash
ssh -i ~/.ssh/cmtr-iacp1ebx ec2-user@<instance_public_ip>
```

Conexión exitosa con la llave privada local — objetivo 10 del enunciado cumplido antes de destruir.

## Movimiento 5 — Limpieza local y push

```bash
exit
terraform destroy -auto-approve
```

El código (`main.tf`, `variables.tf`, `ssh.tf`, `ec2.tf`, `versions.tf`, `outputs.tf`, `terraform.tfvars`, `.gitignore`, `.terraform.lock.hcl`) se subió al repo `devops-sandbox`.

**Nota:** en la primera corrida de verificación se me olvidó confirmar el push antes de correr el checker de la plataforma — falló con `No such file or directory` en `main.tf`/`variables.tf` porque el repo remoto todavía no tenía el código. Se corrigió comiteando y empujando el código, y la segunda corrida pasó sin problema.

## Movimiento 6 — Verificación en la plataforma

Mismos 3 campos del lab anterior, más uno nuevo:

- **Repository HTTPS URL with embedded token:** `https://<usuario-github>:<PAT>@github.com/cesarbuitragorey/devops-sandbox.git`
- **Repository branch:** `main`
- **Repository folder:** `05-terraform/1.2-aws-iac-with-terraform-create-resources-for-ssh-authentication/02-practica`
- **Your generated public key:** contenido de `~/.ssh/cmtr-iacp1ebx.pub` — como la clave no vive en el repo, el checker la necesita aparte para poder exportar su propio `TF_VAR_ssh_key` y correr `apply` de forma reproducible.

15/15 checks pasados — ver [03-resultados](../03-resultados/README.md).

## Movimiento 7 — Limpieza final

Se usó el botón **"Destroy Resources"** de la plataforma para eliminar la infraestructura desplegada durante la verificación.
