# Práctica — Task 1.11: AWS IaC with Terraform: Move State to Other Backends

## Enunciado de la tarea

### AWS IaC with Terraform: Move State to Other Backends

#### The Goal of the Task

To learn how to use the `terraform init -migrate-state` command to migrate a Terraform state file from one S3 backend to another. The task involves updating the backend configuration, running the state migration, and confirming that the existing AWS infrastructure remains unchanged.

The goal is to successfully migrate Terraform state management to the new backend without recreating, deleting, or modifying existing AWS resources.

#### Common Task Requirements

While working on the task, follow these requirements:

- Use Terraform `required_version` `>= 1.5.7`.
- Do not delete, recreate, or manually modify existing AWS resources during migration.
- Migrate backend state by using `terraform init -migrate-state`; do not create a new infrastructure deployment.
- Keep backend configuration consistent with the target S3 bucket `cmtr-iacp1ebx-backend-new-bucket-1791205963` and key `tf_code.tfstate`.
- Verify that Terraform still manages the same infrastructure after migration and that `terraform plan` shows no changes.
- Keep the Terraform configuration valid and properly formatted (`terraform validate`, `terraform fmt`).

#### Check Results

Once you complete the task, enter your repository HTTPS URL with a Personal Access Token in the Repository HTTPS URL with embedded token field. If needed, provide any additional input parameters, then click the `Verification` button. During verification, the platform will automatically evaluate your solution and display the final result. A score of 100% means all checks passed successfully. If any checks fail, feedback will be shown so you can review and improve your solution.

Note: All previously created infrastructure will be redeployed from scratch during each new verification. This process can take some time, so please be patient.

After starting the task, you have 2.5 hours to complete verification. If verification is not completed within this time, all existing infrastructure will be destroyed and you will need to restart the task.

#### Pre-created Environment

The following items are already prepared for you:

- Original S3 bucket that stores the Terraform state file: `cmtr-iacp1ebx-backend-bucket-1791205963`
- New S3 bucket that will store the migrated Terraform state file: `cmtr-iacp1ebx-backend-new-bucket-1791205963`
- Terraform state backend key: `tf_code.tfstate`
- IAM policy resource name managed by the Terraform state: `custom_policy`

The current Terraform state is stored in `cmtr-iacp1ebx-backend-bucket-1791205963` and must be migrated to `cmtr-iacp1ebx-backend-new-bucket-1791205963`.

#### Task Resources

All region-specific resources are created in the `eu-west-1` region.

- Original S3 backend bucket `cmtr-iacp1ebx-backend-bucket-1791205963`: stores the current Terraform state file.
- New S3 backend bucket `cmtr-iacp1ebx-backend-new-bucket-1791205963`: will store the migrated Terraform state file.
- Terraform state key `tf_code.tfstate`: identifies the state file inside the S3 bucket.
- `terraform init -migrate-state` command: migrates Terraform state from one backend to another.
- IAM policy `custom_policy`: an existing AWS resource that must remain unchanged during migration.

#### Objectives

1. Gain an understanding of the [terraform init -migrate-state](https://www.terraform.io/cli/commands/init#backend-initialization) command and how it is used to migrate Terraform backend state from one S3 bucket to another without changing existing resources.
2. Create a fork of the [repository](https://gitlab.com/cmtr/module_aws_typ2_task11) and configure access so you can work with the project.
3. Initialize Terraform with the current backend that uses the S3 bucket `cmtr-iacp1ebx-backend-bucket-1791205963`:
4. Migrate the existing Terraform state from the current `cmtr-iacp1ebx-backend-bucket-1791205963` bucket to the new backend `cmtr-iacp1ebx-backend-new-bucket-1791205963` bucket.
5. Run validation and formatting commands to confirm that the Terraform configuration is correct and properly formatted.
6. Push your updated files to your repository and provide the repository link for verification.

*(En el enunciado copiado, el bloque de código del objetivo 3 llegó vacío; ahí iba el comando `terraform init` con el backend actual, ver Fase 1 abajo.)*

#### Verification

Use the following checks to verify that your solution is correct:

1. Confirm that the Terraform state file exists in the new S3 bucket `cmtr-iacp1ebx-backend-new-bucket-1791205963` under the key `tf_code.tfstate`.
2. Confirm that Terraform uses the new S3 backend by reviewing the backend configuration.
3. Verify that the contents of the migrated state file in `cmtr-iacp1ebx-backend-new-bucket-1791205963` match the original state file from `cmtr-iacp1ebx-backend-bucket-1791205963`.
4. Run `terraform plan` and verify that Terraform detects no infrastructure changes. If the state migration is completed correctly, Terraform must continue managing the existing infrastructure from the new backend without proposing any changes to the AWS resources.
5. Open the AWS Management Console and verify that the IAM policy `custom_policy` was not deleted, recreated, or modified during the migration.
6. Confirm that the existing AWS infrastructure remains unchanged.

Note: Before running task verification:
- Push or update your Terraform configuration in your Git repository.
- Ensure the backend migration is complete and Terraform is initialized against the new backend.

To pass verification, your repository must contain the final Terraform code and the existing AWS infrastructure must remain unchanged.

**Región:** `eu-west-1` (backend S3; el provider del repo original usa `us-east-1`, irrelevante para IAM, que es global) — Cuenta `980921730449`

**Entorno real usado:** código en este directorio (`02-practica`), corrido localmente vía CLI (Git Bash). **No se hizo fork del repo de GitLab:** se copió su contenido a `devops-sandbox` y se usó el campo `Repository folder` de la plataforma, igual que en los labs anteriores.

---

## Fase 1 — Inicializar con el backend actual y respaldar el state

El `providers.tf` del repo original trae el backend S3 con valores vacíos (`bucket = ""`, `key = ""`, `region = ""`), que se completan con `-backend-config`. Se agregó `required_version = ">= 1.5.7"` a `main.tf`.

```bash
terraform init -backend-config="bucket=cmtr-iacp1ebx-backend-bucket-1791205963" -backend-config="key=tf_code.tfstate" -backend-config="region=eu-west-1"
terraform state list
terraform state pull > backup_original.tfstate
terraform plan
```

`state list` mostró `aws_iam_policy.custom_policy`. El backup `backup_original.tfstate` quedó gitignoreado.

## Fase 2 — Cambiar el backend en el código y migrar

Se editó `providers.tf` para apuntar al backend nuevo (consistente con lo que pide el enunciado):

```hcl
terraform {
  backend "s3" {
    bucket = "cmtr-iacp1ebx-backend-new-bucket-1791205963"
    key    = "tf_code.tfstate"
    region = "eu-west-1"
  }
}
```

Y se migró el state. Se usó `-force-copy` para que Terraform copie el state sin quedarse esperando la confirmación interactiva ("Do you want to copy existing state to the new backend?"):

```bash
terraform init -migrate-state -force-copy
```

## Fase 3 — Verificar la migración

```bash
terraform state list
terraform state pull > migrated.tfstate
diff backup_original.tfstate migrated.tfstate
terraform fmt -check
terraform validate
terraform plan
```

- `state list` desde el backend nuevo mostró `aws_iam_policy.custom_policy`.
- El `diff` entre el state original y el migrado mostró **una sola diferencia: el campo `lineage`** (el identificador interno del historial del state, que Terraform regenera en el backend destino). Los recursos y sus atributos eran idénticos, incluyendo el ARN de la política.
- `fmt` y `validate` correctos, `plan` con *No changes*.

En este lab **no se corre `terraform destroy`**: la política debe quedar intacta en AWS.

## Fase 4 — Push y verificación en la plataforma

- **Repository branch:** `main`
- **Repository folder:** `05-terraform/1.11-aws-iac-with-terraform-move-state-to-other-backends/02-practica`
- **Repository HTTPS URL:** con PAT embebido.

7/7 checks pasados en el primer intento — ver [03-resultados](../03-resultados/README.md).

## Fase 5 — Limpieza final

Se usó el botón **"Destroy Resources"** de la plataforma.
