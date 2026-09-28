# Práctica — Task 1.3: AWS IaC with Terraform: Create an Object Storage

## Enunciado de la tarea

### AWS IaC with Terraform: Create an Object Storage

#### The Goal of the Task

To create an Amazon S3 bucket using Terraform for object storage within your infrastructure. The task involves adding the required tag to the bucket and ensuring it remains privately accessible.

By the end of the task, you will have a working Terraform configuration that successfully creates an S3 bucket with the specified name and tags.

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

All region-specific resources should be created in the `eu-west-1` region.

- Terraform `aws_s3_bucket` resource: creates and manages an Amazon S3 bucket in AWS enabling infrastructure-as-code management of S3 buckets and their configurations.
- Local file `storage.tf`: contains the Terraform configuration for the S3 bucket resource.
- Tags `Project=cmtr-iacp1ebx`: a key-value pair used for organizing and managing AWS resources. This tag helps in categorizing and filtering resources, tracking costs, and managing permissions in AWS based on the project they are associated with.
- S3 bucket name `cmtr-iacp1ebx-bucket-1790338985`: is the name of the S3 bucket you will create, and it must be globally unique across all AWS accounts and regions.

#### Objectives

1. Create the file `storage.tf` for defining all storage-related Terraform resources in it.
2. Create an S3 bucket by using the `aws_s3_bucket` resource.
3. Set the bucket name to `cmtr-iacp1ebx-bucket-1790338985`.
4. Add the required tag to the S3 bucket:
   - `Project=cmtr-iacp1ebx`
5. Validate and format your Terraform configuration:
   - run `terraform fmt`;
   - run `terraform validate`.
6. Run `terraform plan` to preview the infrastructure changes before deployment and ensure that there are no errors in your configuration.

#### Verification

1. Make sure the Terraform plan and apply commands run without errors.
2. In the AWS Console, open S3 and verify that the bucket `cmtr-iacp1ebx-bucket-1790338985` was created successfully.
3. Verify that the bucket has the required tag: `Project=cmtr-iacp1ebx`.
4. Verify that the bucket uses private access permissions and is not publicly accessible.

Note: Before running task verification:
- Push or update your Terraform configuration in your Git repository.
- Delete the AWS resources you created during the task by running `terraform destroy`.

To pass verification, your repository must contain the final Terraform code, but the deployed resources must already be removed.

**Región:** `eu-west-1` — Cuenta `442042516187`

**Entorno real usado:** código Terraform en este mismo directorio (`02-practica`), corrido localmente vía CLI (Git Bash).

---

## Movimiento 1 — Flujo local de Terraform

```bash
cd "05-terraform/1.3-aws-iac-with-terraform-create-an-object-storage/02-practica"

terraform init
terraform fmt
terraform validate
terraform plan
terraform apply -auto-approve
```

`apply` creó 2 recursos sin errores: `aws_s3_bucket.this` y `aws_s3_bucket_public_access_block.this`.

## Movimiento 2 — Limpieza y push

```bash
terraform destroy -auto-approve
```

Aprendiendo del lab anterior (donde se me olvidó pushear antes de verificar), esta vez el código se comiteó y subió al repo `devops-sandbox` **antes** de correr la verificación en la plataforma.

## Movimiento 3 — Verificación en la plataforma

- **Repository branch:** `main`
- **Repository folder:** `05-terraform/1.3-aws-iac-with-terraform-create-an-object-storage/02-practica`
- **Repository HTTPS URL:** con PAT embebido, igual que en los labs anteriores.

14/14 checks pasados en el primer intento — ver [03-resultados](../03-resultados/README.md).

## Movimiento 4 — Limpieza final

Se usó el botón **"Destroy Resources"** de la plataforma para eliminar la infraestructura desplegada durante la verificación.
