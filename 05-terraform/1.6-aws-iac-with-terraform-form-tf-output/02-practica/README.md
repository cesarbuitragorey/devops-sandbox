# Práctica — Task 1.6: AWS IaC with Terraform: Form TF Output

## Enunciado de la tarea

> Crear la misma red que en la task 1.1 (VPC `cmtr-iacp1ebx-01-vpc`, 3 subnets públicos, IGW, route table), pero con el foco puesto en `outputs.tf`: debe exponer `vpc_id`, `vpc_cidr`, `public_subnet_ids`, `public_subnet_cidr_block`, `public_subnet_availability_zone`, `internet_gateway_id` y `routing_table_id`.

**Región:** `eu-west-1` — Cuenta `913524900817`

**Entorno real usado:** código Terraform en este mismo directorio (`02-practica`), corrido localmente vía CLI (Git Bash).

---

## Movimiento 1 — Reutilizar el diseño de la task 1.1

Se copió el mismo patrón `for_each` sobre `map(object(...))` para los 3 subnets (evita hardcodear nombres de recurso), y se ajustó únicamente `outputs.tf` a los 7 nombres exactos pedidos por este enunciado.

## Movimiento 2 — Flujo local de Terraform

```bash
cd "05-terraform/1.6-aws-iac-with-terraform-form-tf-output/02-practica"

terraform init
terraform fmt
terraform validate
terraform plan
terraform apply -auto-approve
```

`apply` creó 9 recursos sin errores, con los 7 outputs mostrados correctamente en consola (objetivo 10 del enunciado).

## Movimiento 3 — Limpieza y push

```bash
terraform destroy -auto-approve
```

Código comiteado y subido a `devops-sandbox` **antes** de correr la verificación en la plataforma.

## Movimiento 4 — Verificación en la plataforma

- **Repository branch:** `main`
- **Repository folder:** `05-terraform/1.6-aws-iac-with-terraform-form-tf-output/02-practica`
- **Repository HTTPS URL:** con PAT embebido.

29/29 checks pasados en el primer intento — ver [03-resultados](../03-resultados/README.md).

## Movimiento 5 — Limpieza final

Se usó el botón **"Destroy Resources"** de la plataforma.
