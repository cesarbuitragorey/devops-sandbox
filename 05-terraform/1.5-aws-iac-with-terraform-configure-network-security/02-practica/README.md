# Práctica — Task 1.5: AWS IaC with Terraform: Configure Network Security

## Enunciado de la tarea

> Configurar seguridad de red con Terraform sobre una VPC e instancias (pública/privada) ya pre-creadas: 3 security groups (SSH, HTTP público, HTTP privado) con reglas de ingress específicas, usando `source_security_group_id` para el tráfico público→privado, y adjuntarlos a las instancias existentes sin tocar el security group de testing de la plataforma.

**Región:** `eu-west-1` — Cuenta `891612557805`

**Entorno real usado:** código Terraform en este mismo directorio (`02-practica`), corrido localmente vía CLI (Git Bash).

---

## Movimiento 1 — Obtener la IP pública propia

```bash
curl -s https://checkip.amazonaws.com
```

Se agregó junto a la IP de ejemplo del enunciado en `allowed_ip_range` (`terraform.tfvars`).

## Movimiento 2 — Flujo local de Terraform

```bash
cd "05-terraform/1.5-aws-iac-with-terraform-configure-network-security/02-practica"

terraform init
terraform fmt
terraform validate
terraform plan
terraform apply -auto-approve
```

`apply` creó 13 recursos sin errores: 3 security groups, 6 reglas de ingress (SSH+ICMP, HTTP+ICMP, HTTP privado+ICMP vía `source_security_group_id`) y 4 `aws_network_interface_sg_attachment` (2 por instancia).

## Movimiento 3 — Verificar acceso HTTP al instance público

```bash
aws ec2 describe-instances --instance-ids i-0a65b2611e2a908e6 \
  --query 'Reservations[0].Instances[0].PublicIpAddress' --output text

curl -s http://<public-ip>
```

Confirmó la página de bienvenida de Nginx — objetivo 5 del enunciado cumplido antes de destruir.

## Movimiento 4 — Limpieza y push

```bash
terraform destroy -auto-approve
```

Código comiteado y subido a `devops-sandbox` **antes** de correr la verificación en la plataforma.

## Movimiento 5 — Verificación en la plataforma

- **Repository branch:** `main`
- **Repository folder:** `05-terraform/1.5-aws-iac-with-terraform-configure-network-security/02-practica`
- **Repository HTTPS URL:** con PAT embebido.

18/18 checks pasados en el primer intento — ver [03-resultados](../03-resultados/README.md).

## Movimiento 6 — Limpieza final

Se usó el botón **"Destroy Resources"** de la plataforma.
