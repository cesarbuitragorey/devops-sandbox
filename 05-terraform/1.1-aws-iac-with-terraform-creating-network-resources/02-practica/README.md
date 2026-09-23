# Práctica — Task 1: AWS IaC with Terraform: Creating Network Resources

## Enunciado de la tarea

> Crear, con Terraform, una VPC (`cmtr-iacp1ebx-01-vpc`, CIDR `10.10.0.0/16`), 3 subnets públicos en `eu-west-1a/b/c`, un Internet Gateway y una route table que dirija el tráfico `0.0.0.0/0` hacia el IGW. Sin backend remoto, sin `local-exec`, sin `prevent_destroy`. Verificación vía repo Git (la plataforma clona el repo y corre el flujo de Terraform).

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
