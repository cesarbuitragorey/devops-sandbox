# Práctica — Task 1.4: AWS IaC with Terraform: Creating IAM Resources

## Enunciado de la tarea

### AWS IaC with Terraform: Creating IAM Resources

#### The Goal of the Task

To create and configure AWS Identity and Access Management (IAM) resources using Terraform. The task involves creating an IAM group, preparing a custom IAM policy for S3 bucket access, and creating an IAM role with an instance profile for the EC2 service.

The primary objective is to practice working with IAM resources in Terraform and to gain a clear understanding of how permissions, trust relationships, and instance profiles function together.

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

The following resource is already created for you:

- S3 bucket `cmtr-iacp1ebx-bucket-1790635311` in the `eu-west-1` region, which will be used in the IAM policy for granting permissions.

#### Task Resources

All region-specific resources should be created in the `eu-west-1` region.

- AWS `aws_iam_group` resource: creates and manages an IAM group to organize users and manage permissions collectively
- AWS `aws_iam_policy` resource: creates a custom IAM policy with specific permissions
- AWS `aws_iam_role` resource: creates a role that trusted AWS services can assume to perform actions on your behalf
- AWS `aws_iam_instance_profile` resource: associates an IAM role with an EC2 instance profile that can be attached to EC2 instances
- Local files:
  - `iam.tf`: defines all IAM-related Terraform resources
  - `policy.json`: contains the IAM policy document for S3 bucket access
- Required tag:
  - `Project=cmtr-iacp1ebx`

#### Objectives

1. Create the file `iam.tf` for all IAM-related Terraform resources.
2. Create an IAM group named `cmtr-iacp1ebx-iam-group`.
3. Create a custom IAM policy:
   - name the policy `cmtr-iacp1ebx-iam-policy`;
   - store the policy document in `policy.json`;
   - use the `templatefile()` function to insert the S3 bucket name into the policy document;
   - grant only write permissions (e.g., s3:PutObject, s3:DeleteObject) for the S3 bucket `cmtr-iacp1ebx-bucket-1790635311`.
4. Create an IAM role named `cmtr-iacp1ebx-iam-role` and configure the trust relationship so that EC2 can assume it (use `ec2.amazonaws.com` as the trusted service).
5. Attach the custom IAM policy to the IAM role.
6. Create an IAM instance profile named `cmtr-iacp1ebx-iam-instance-profile` and associate it with the IAM role.
7. Apply the required tag to all created resources:
   - `Project=cmtr-iacp1ebx`
8. Format, validate, review, and apply your configuration:
   - Run `terraform fmt` to format your code
   - Run `terraform validate` to ensure your configuration is correct
   - Run `terraform plan` to preview the infrastructure changes
   - Run `terraform apply` to create the IAM resources in AWS

#### Verification

1. Confirm that both required files exist: `iam.tf` and `policy.json`.
2. Inspect the Terraform outputs from `terraform plan` to ensure there are no errors and all configurations have been applied correctly.
3. In the AWS Console, open IAM and verify that the group, policy, role, and instance profile have been created with the correct names and configurations.
4. Verify that the policy document references the S3 bucket `cmtr-iacp1ebx-bucket-1790635311` and grants only write permissions.
5. Verify that the IAM role trust relationship allows the EC2 service (`ec2.amazonaws.com`) to assume the role.
6. Verify that the instance profile is associated with the correct IAM role.
7. Confirm that all created resources have the `Project=cmtr-iacp1ebx` tag.

Note: Before running task verification:
- Push or update your Terraform configuration in your Git repository.
- Delete the AWS resources you created during the task by running `terraform destroy`.

To pass verification, your repository must contain the final Terraform code, but the deployed resources must already be removed.

**Región:** `eu-west-1` — Cuenta `180503893306`

**Entorno real usado:** código Terraform en este mismo directorio (`02-practica`), corrido localmente vía CLI (Git Bash).

---

## Movimiento 1 — Flujo local de Terraform

```bash
cd "05-terraform/1.4-aws-iac-with-terraform-creating-iam-resources/02-practica"

terraform init
terraform fmt
terraform validate
terraform plan
terraform apply -auto-approve
```

`apply` creó 5 recursos sin errores: `aws_iam_group.this`, `aws_iam_policy.this`, `aws_iam_role.this`, `aws_iam_role_policy_attachment.this`, `aws_iam_instance_profile.this`. El plan confirmó que la policy resuelta por `templatefile()` apuntaba correctamente al ARN real del bucket pre-creado (`arn:aws:s3:::cmtr-iacp1ebx-bucket-1790635311/*`) con solo `s3:PutObject`/`s3:DeleteObject`.

## Movimiento 2 — Limpieza y push

```bash
terraform destroy -auto-approve
```

Código comiteado y subido a `devops-sandbox` **antes** de correr la verificación (siguiendo la corrección de los labs anteriores).

## Movimiento 3 — Verificación en la plataforma

- **Repository branch:** `main`
- **Repository folder:** `05-terraform/1.4-aws-iac-with-terraform-creating-iam-resources/02-practica`
- **Repository HTTPS URL:** con PAT embebido.

16/16 checks pasados en el primer intento — ver [03-resultados](../03-resultados/README.md).

## Movimiento 4 — Limpieza final

Se usó el botón **"Destroy Resources"** de la plataforma.
