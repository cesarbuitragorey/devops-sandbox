# Práctica — Task 1.4: AWS IaC with Terraform: Creating IAM Resources

## Enunciado de la tarea

> Crear, con Terraform, un grupo IAM (`cmtr-iacp1ebx-iam-group`), una policy personalizada de solo-escritura sobre el bucket S3 pre-creado (`cmtr-iacp1ebx-bucket-1790635311`), un rol IAM (`cmtr-iacp1ebx-iam-role`) con trust hacia `ec2.amazonaws.com`, y un instance profile (`cmtr-iacp1ebx-iam-instance-profile`) asociado a ese rol.

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
