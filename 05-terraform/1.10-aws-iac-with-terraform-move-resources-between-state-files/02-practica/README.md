# Práctica — Task 1.10: AWS IaC with Terraform: Move Resources between State Files

## Enunciado de la tarea

### AWS IaC with Terraform: Move Resources between State Files

#### The Goal of the Task

To learn how to use the `terraform state mv` command to move a resource from one Terraform state file to another. The task involves updating both Terraform configurations to ensure the moved resource is correctly tracked without being recreated or deleted in the AWS cloud infrastructure.

#### Common Task Requirements

While working on the task, follow these requirements:

- Use Terraform `required_version` `>= 1.5.7`.
- Do not delete, recreate, or manually modify the existing IAM policy in AWS.
- Move Terraform state ownership by using `terraform state mv`; do not create a duplicate resource in AWS.
- Keep each resource declared only in the configuration where it is managed after the move.
- Ensure both source and destination configurations are valid and properly formatted (`terraform validate`, `terraform fmt`).
- Ensure `terraform plan` does not propose infrastructure changes in either directory after the state move.

#### Check Results

Once you complete the task, enter your repository HTTPS URL with a Personal Access Token in the Repository HTTPS URL with embedded token field. If needed, provide any additional input parameters, then click the `Verification` button. During verification, the platform will automatically evaluate your solution and display the final result. A score of 100% means all checks passed successfully. If any checks fail, feedback will be shown so you can review and improve your solution.

Note: All previously created infrastructure will be redeployed from scratch during each new verification. This process can take some time, so please be patient.

After starting the task, you have 2.5 hours to complete verification. If verification is not completed within this time, all existing infrastructure will be destroyed and you will need to restart the task.

#### Pre-created Environment

The following items are already prepared for you:

- Remote Terraform state bucket: `cmtr-iacp1ebx-backend-bucket-1790947407`
- First directory with Terraform files: `tf_code_1`
- Second directory with Terraform files: `tf_code_2`
- IAM policy resource name: `custom_policy`

The `aws_iam_policy` resource is currently managed from the first Terraform state and must be moved to the second Terraform state.

#### Task Resources

All region-specific resources are created in the `eu-west-1` region.

- Terraform state bucket `cmtr-iacp1ebx-backend-bucket-1790947407`: stores the current remote Terraform state files.
- `terraform state mv` command: the command you need to use to move the resource between state files.
- First Terraform directory `tf_code_1`: contains the source configuration and uses the state file `tf_code_1.tfstate`.
- Second Terraform directory `tf_code_2`: contains the destination configuration and uses the state file `tf_code_2.tfstate`.
- IAM policy `custom_policy`: the AWS resource that must be moved between states.

#### Objectives

1. Gain an understanding of the `terraform state mv` command and how to use it to move resources between state files.
2. Create a fork of the [repository](https://gitlab.com/cmtr/module_aws_typ2_task10) and configure access rights to your forked repository.
3. Initialize the Terraform configuration in the first directory by using the state file `tf_code_1.tfstate`.
4. Initialize the Terraform configuration in the second directory by using the state file `tf_code_2.tfstate`.
5. Move the `aws_iam_policy` resource from the `tf_code_1.tfstate` state file to the `tf_code_2.tfstate` state file by using the `terraform state mv` command.
6. Remove the resource configuration from the Terraform files in `tf_code_1` and add it to the Terraform files in `tf_code_2`.
7. Make sure the resource is only managed from the destination configuration after the move.
8. Run validation and formatting commands to confirm that both Terraform configurations are correct.
9. Once you complete the move, run the following checks for both configurations to confirm that the resource is moved correctly and no changes are proposed by Terraform:
   - `terraform plan` to confirm that no infrastructure changes are detected
   - `terraform validate` to check syntax and configuration correctness
   - `terraform fmt` to ensure the code follows Terraform formatting standards
10. Push your updated files to your repository and provide the repository link for verification.

*(En el enunciado copiado, los bloques de código de los objetivos 3 y 4 llegaron vacíos; ahí iban los comandos `terraform init` con el backend de cada directorio, ver Fase 1 abajo.)*

#### Verification

Use the following checks to verify that your solution is correct:

1. Confirm that the `aws_iam_policy` resource appears in the `tf_code_2.tfstate` state file after the move.
2. Confirm that the `aws_iam_policy` resource no longer appears in the `tf_code_1.tfstate` state file.
3. Run `terraform plan` in both `tf_code_1` and `tf_code_2` and verify that Terraform detects no changes.
4. Open the AWS Management Console and verify that the IAM policy `custom_policy` was not deleted or recreated during the move.
5. Confirm that the resource in AWS remains unchanged.

Important:
- Do not recreate the IAM policy manually.
- Do not delete the resource from AWS and deploy it again.
- The goal of this task is to move Terraform state ownership without changing the actual AWS resource.

Note: Before running task verification:
- Push or update your Terraform configuration in your Git repository.
- Ensure both state files and both Terraform directories are updated consistently after running `terraform state mv`.

To pass verification, your repository must contain the final Terraform code and the IAM policy must remain unchanged in AWS.

**Región:** `eu-west-1` (backend S3; el provider del repo original usa `us-east-1`, irrelevante para IAM, que es global) — Cuenta `296062559166`

**Entorno real usado:** código en este directorio (`02-practica`, con `tf_code_1` y `tf_code_2`), corrido localmente vía CLI (Git Bash). **No se hizo fork del repo de GitLab:** se copió su contenido a `devops-sandbox` y se usó el campo `Repository folder` de la plataforma, igual que en los labs anteriores.

---

## Fase 1 — Inicializar ambos directorios y respaldar los states

Los `providers.tf` del repo original traen el backend S3 con valores vacíos (`bucket = ""`, `key = ""`, `region = ""`), que se completan con `-backend-config` al inicializar. Se agregó además `required_version = ">= 1.5.7"` a ambos `main.tf`, como pide el enunciado.

```bash
BUCKET=cmtr-iacp1ebx-backend-bucket-1790947407

cd tf_code_1
terraform init -backend-config="bucket=$BUCKET" -backend-config="key=tf_code_1.tfstate" -backend-config="region=eu-west-1"
terraform state list
terraform state pull > ../backup_tf_code_1.tfstate
terraform plan
cd ..

cd tf_code_2
terraform init -backend-config="bucket=$BUCKET" -backend-config="key=tf_code_2.tfstate" -backend-config="region=eu-west-1"
terraform state list
terraform state pull > ../backup_tf_code_2.tfstate
terraform plan
cd ..
```

Estado inicial confirmado: `tf_code_1` listaba `aws_iam_policy.custom_policy` y su `plan` daba *No changes*; `tf_code_2` estaba vacío, también sin cambios. Los backups `*.tfstate` quedan gitignoreados.

## Fase 2 — Mover el recurso

Se trabajó sobre copias locales de los states (los backups quedaron intactos), y se subió primero el state destino y después el origen, de modo que el recurso nunca quedara sin dueño en ningún momento:

```bash
cp backup_tf_code_1.tfstate work_tf_code_1.tfstate

cd tf_code_1
terraform state mv -state=../work_tf_code_1.tfstate -state-out=../work_tf_code_2.tfstate aws_iam_policy.custom_policy aws_iam_policy.custom_policy
cd ..

cd tf_code_2
terraform state push ../work_tf_code_2.tfstate
terraform state list
cd ..

cd tf_code_1
terraform state push ../work_tf_code_1.tfstate
terraform state list
cd ..
```

`state mv` reportó *Successfully moved 1 object(s)*; después `tf_code_2` listaba el recurso y `tf_code_1` quedó sin ninguna entrada.

Paralelamente se editó la configuración: `tf_code_1/resources.tf` quedó vacío (sin el recurso) y `tf_code_2/resources.tf` se creó con la definición idéntica del `aws_iam_policy.custom_policy` (mismos atributos, para que el plan no detecte diferencias).

## Fase 3 — Verificación local

```bash
cd tf_code_1 && terraform fmt -check && terraform validate && terraform plan; cd ..
cd tf_code_2 && terraform fmt -check && terraform validate && terraform plan; cd ..
```

En ambos directorios: formato correcto, configuración válida y `plan` con **No changes** — la política de AWS no se tocó. En este lab **no se corre `terraform destroy`**: la política debe quedar intacta en AWS.

## Fase 4 — Push y verificación en la plataforma

- **Repository branch:** `main`
- **Repository folder:** `05-terraform/1.10-aws-iac-with-terraform-move-resources-between-state-files/02-practica`
- **Repository HTTPS URL:** con PAT embebido.

13/13 checks pasados en el primer intento — ver [03-resultados](../03-resultados/README.md).

## Fase 5 — Limpieza final

Se usó el botón **"Destroy Resources"** de la plataforma.
