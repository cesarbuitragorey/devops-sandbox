# Práctica — Task 1.3: AWS IaC with Terraform: Create an Object Storage

## Enunciado de la tarea

> Crear, con Terraform, un bucket S3 privado (`cmtr-iacp1ebx-bucket-1790338985`) con el tag `Project=cmtr-iacp1ebx`, sin acceso público.

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
