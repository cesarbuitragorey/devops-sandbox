# Práctica — Task 1.12: AWS IaC with Terraform: Import Resources

## Enunciado de la tarea

### AWS IaC with Terraform: Import Resources

#### The Goal of the Task

To learn how to import an existing AWS IAM policy into Terraform state management using the `terraform import` command. This approach allows you to bring an existing AWS resource under Terraform control without recreating or modifying it. The imported resource will be linked to a corresponding resource block in `.tf` code, enabling Terraform to track and manage it moving forward.

The task involves defining the existing IAM policy `cmtr-iacp1ebx-iam-policy` in Terraform code, retrieving its ARN, and importing it into the Terraform state. After the import, Terraform must correctly recognize the resource, and `terraform plan` should show no unexpected changes.

#### Common Task Requirements

While working on the task, follow these requirements:

- Use Terraform `required_version` `>= 1.5.7`.
- Do not delete, recreate, or manually modify the existing IAM policy in AWS.
- Define the resource in `resources.tf` before import and ensure the configuration matches the existing IAM policy.
- Import the existing IAM policy into Terraform state by using `terraform import` with the correct ARN.
- After import, ensure `terraform plan` does not propose unexpected infrastructure changes.
- Keep the Terraform configuration valid and properly formatted (`terraform validate`, `terraform fmt`).

#### Check Results

Once you complete the task, enter your repository HTTPS URL with a Personal Access Token in the Repository HTTPS URL with embedded token field. If needed, provide any additional input parameters, then click the `Verification` button. During verification, the platform will automatically evaluate your solution and display the final result. A score of 100% means all checks passed successfully. If any checks fail, feedback will be shown so you can review and improve your solution.

Note: All previously created infrastructure will be redeployed from scratch during each new verification. This process can take some time, so please be patient.

After starting the task, you have 2.5 hours to complete verification. If verification is not completed within this time, all existing infrastructure will be destroyed and you will need to restart the task.

#### Pre-created Environment

The following items are already prepared for you:

- Remote Terraform state file in bucket: `cmtr-iacp1ebx-backend-bucket-1791208211`
- Terraform state key: `tf_code.tfstate`
- Working directory with Terraform code: `tf_code`
- IAM policy in AWS: `cmtr-iacp1ebx-iam-policy`
- Terraform resource type to use: `aws_iam_policy`
- Terraform file for the resource definition: `resources.tf`

The IAM policy `cmtr-iacp1ebx-iam-policy` already exists in AWS and must be imported into Terraform state.

#### Task Resources

All region-specific resources are created in the `eu-west-1` region.

- Terraform state file in bucket `cmtr-iacp1ebx-backend-bucket-1791208211`: stores the infrastructure state managed by Terraform.
- Terraform state key `tf_code.tfstate`: identifies the specific state file for this task.
- Working directory `tf_code`: the directory where you will create and manage your Terraform configuration files.
- IAM policy `cmtr-iacp1ebx-iam-policy`: the existing AWS resource that must be imported into Terraform state.
- Terraform resource type `aws_iam_policy`: the Terraform resource type used to manage the IAM policy.
- `resources.tf`: the Terraform file where you must define the imported IAM policy.
- `terraform import` command: imports an existing AWS resource into Terraform state.

#### Objectives

1. Gain an understanding of the [terraform import](https://www.terraform.io/cli/commands/import) command and how it is used to bring existing AWS resources under Terraform state management.
2. Create a fork of the [repository](https://gitlab.com/cmtr/module_aws_typ2_task12) and configure access so you can work with the project.
3. Initialize Terraform in the `tf_code` directory by using the provided remote state configuration.
4. Add the IAM policy resource definition to `resources.tf`.
5. Make sure the Terraform resource definition matches the existing IAM policy in AWS.
6. Retrieve the ARN of the IAM policy by using the AWS CLI.
7. Run `terraform import` with the IAM policy ARN to import the existing AWS resource into Terraform state.
8. Run `terraform plan` and confirm that Terraform detects no unexpected changes after the import.
9. Run validation and formatting commands to confirm that the Terraform configuration is correct.
10. Push your updated files to your repository and provide the repository link for verification.

*(En el enunciado copiado, el bloque de código del objetivo 3 llegó vacío; ahí iba el comando `terraform init` con la configuración del backend remoto, ver Fase 1 abajo.)*

#### Verification

Use the following steps to verify that your solution is correct:

1. Confirm that `terraform import` completed successfully without errors.
2. Run `terraform plan` and verify that output shows no unexpected changes.
3. Confirm that the imported IAM policy matches the Terraform definition in `resources.tf`.
4. Open the AWS Console and navigate to IAM policy `cmtr-iacp1ebx-iam-policy` to verify that the policy name, description, actions, and resources match the Terraform configuration.
5. Confirm that Terraform does not recreate or modify the imported IAM policy.
6. Run `terraform validate` and confirm that there are no validation errors.
7. Run `terraform fmt` and confirm that the Terraform files are properly formatted.

Note: Before running task verification:
- Push or update your Terraform configuration in your Git repository.

To pass verification, your repository must contain the final Terraform code, and the imported IAM policy must remain unchanged in AWS.

**Región:** `eu-west-1` (backend S3; el provider del repo original usa `us-east-1`, irrelevante para IAM, que es global) — Cuenta `913524907044`

**Entorno real usado:** código en este directorio (`02-practica`), corrido localmente vía CLI (Git Bash). **No se hizo fork del repo de GitLab:** se copió su contenido a `devops-sandbox` y se usó el campo `Repository folder` de la plataforma. El repo original tiene los archivos en la raíz (no en un subdirectorio `tf_code` como menciona el enunciado) y se dejaron igual; el checker los encontró así.

---

## Fase 1 — Inicializar el backend remoto y leer la política real

El repo original trae `resources.tf` **vacío** y el backend S3 con valores vacíos en `providers.tf` (que se completan con `-backend-config`). Se agregó `required_version = ">= 1.5.7"` a `main.tf`. El comando del objetivo 3 y los del objetivo 6:

```bash
terraform init -backend-config="bucket=cmtr-iacp1ebx-backend-bucket-1791208211" -backend-config="key=tf_code.tfstate" -backend-config="region=eu-west-1"
terraform state list

ARN=$(aws iam list-policies --scope Local --query "Policies[?PolicyName=='cmtr-iacp1ebx-iam-policy'].Arn" --output text)
echo "ARN: $ARN"
aws iam get-policy --policy-arn "$ARN"
aws iam get-policy-version --policy-arn "$ARN" --version-id "$(aws iam get-policy --policy-arn "$ARN" --query Policy.DefaultVersionId --output text)"
```

- `state list` salió vacío (el recurso aún no estaba en el state).
- ARN: `arn:aws:iam::913524907044:policy/cmtr-iacp1ebx-iam-policy`.
- Atributos reales: `Path` = `/`, `Description` = `Custom role with limited permissions`, y un documento de política con un único statement `Allow` sobre `ec2:*` y `s3:*` en `Resource: "*"` (versión `2012-10-17`).

## Fase 2 — Escribir `resources.tf` para que coincida y importar

Con esos datos se escribió la definición en `resources.tf`:

```hcl
resource "aws_iam_policy" "custom_policy" {
  name        = "cmtr-iacp1ebx-iam-policy"
  description = "Custom role with limited permissions"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = ["ec2:*", "s3:*"],
        Resource = "*"
      }
    ]
  })
}
```

Primero un `plan` **antes** del import, que propuso *crear* la política (1 to add): el recurso estaba declarado en el código pero sin dueño en el state. Luego el import y las comprobaciones:

```bash
terraform plan
terraform import aws_iam_policy.custom_policy "$ARN"
terraform state list
terraform fmt -check
terraform validate
terraform plan
```

El import terminó con *Import successful!*; `state list` mostró `aws_iam_policy.custom_policy`, `validate` y `fmt` correctos, y el segundo `plan` dio **No changes** — la política en AWS no se tocó. En este lab **no se corre `terraform destroy`**: ya la gestiona Terraform, así que un `destroy` la borraría de AWS.

## Fase 3 — Push y verificación en la plataforma

- **Repository branch:** `main`
- **Repository folder:** `05-terraform/1.12-aws-iac-with-terraform-import-resources/02-practica`
- **Repository HTTPS URL:** con PAT embebido.

7/7 checks pasados en el primer intento — ver [03-resultados](../03-resultados/README.md).

## Fase 4 — Limpieza final

Se usó el botón **"Destroy Resources"** de la plataforma.
