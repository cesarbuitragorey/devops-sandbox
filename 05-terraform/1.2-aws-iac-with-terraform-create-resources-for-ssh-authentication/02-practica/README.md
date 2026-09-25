# Práctica — Task 1.2: AWS IaC with Terraform: Create Resources for SSH Authentication

## Enunciado de la tarea

> Configurar acceso SSH seguro a una EC2 con Terraform: generar un par de llaves SSH, registrar la pública como `aws_key_pair` (`cmtr-iacp1ebx-keypair`), y lanzar una EC2 (`cmtr-iacp1ebx-ec2`) que la use para autenticación — referenciando la VPC/subnet/security group ya creados por la plataforma vía data sources, sin recrearlos.

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
