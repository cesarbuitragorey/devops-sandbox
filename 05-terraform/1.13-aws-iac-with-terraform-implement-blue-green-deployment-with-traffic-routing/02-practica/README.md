# Práctica — Task 1.13: AWS IaC with Terraform: Implement Blue-Green Deployment with Traffic Routing

## Enunciado de la tarea

### AWS IaC with Terraform: Implement Blue-Green Deployment with Traffic Routing

#### The Goal of the Task

To create a Blue-Green deployment in AWS using Terraform. This deployment strategy helps reduce risks during updates by maintaining two separate environments simultaneously. Initially, traffic is directed to one environment (e.g., the Blue environment) while the other (e.g., the Green environment) can be tested safely. Traffic can then be gradually shifted to the Green environment when ready.

The task involves provisioning an Application Load Balancer, two target groups, two launch templates, and two Auto Scaling groups. The Blue and Green environments will serve different web page content to visually demonstrate how weighted traffic routing operates.

#### Common Task Requirements

While working on the task, follow these requirements:

- Do not define a backend in your Terraform configuration. Terraform will use the local backend by default.
- Do not use the `local-exec` provisioner.
- Do not use the `prevent_destroy` lifecycle argument.
- Use `versions.tf` to define the required Terraform and AWS provider versions.
- Set Terraform `required_version` to `>= 1.5.7`.
- Define all variables only in `variables.tf`, and give each variable a valid description and type.
- Define resource names by using variables or generated dynamically/concatenated values, for example by using `locals` and Terraform functions.
- Avoid hardcoding resource names directly in resource blocks, and do not use the `default` argument for task variables.
- Put all non-sensitive input values in `terraform.tfvars`.
- Define outputs only in `outputs.tf`, and give each output a valid description.
- Keep your Terraform code clean and properly formatted. Run `terraform fmt` before committing your code to ensure it follows standard style conventions.

#### Check Results

Once you complete the task, enter your repository HTTPS URL with a Personal Access Token in the Repository HTTPS URL with embedded token field. If needed, provide any additional input parameters, then click the `Verification` button. During verification, the platform will automatically evaluate your solution and display the final result. A score of 100% means all checks passed successfully. If any checks fail, feedback will be shown so you can review and improve your solution.

Note: All previously created infrastructure will be redeployed from scratch during each new verification. This process can take some time, so please be patient.

After starting the task, you have 2.5 hours to complete verification. If verification is not completed within this time, all existing infrastructure will be destroyed and you will need to restart the task.

#### Pre-created Environment

The following AWS resources are already prepared for you in the `eu-west-1` region:

- VPC `cmtr-iacp1ebx-vpc`
- Public subnet `cmtr-iacp1ebx-public-subnet1`
- Public subnet `cmtr-iacp1ebx-public-subnet2`
- Security group `cmtr-iacp1ebx-sg-ssh` for SSH access
- Security group `cmtr-iacp1ebx-sg-http` for HTTP access to EC2 instances
- Security group `cmtr-iacp1ebx-sg-lb` for HTTP access to the Application Load Balancer

You will use these existing networking resources to deploy the Blue and Green environments.

#### Task Resources

All region-specific resources are created in the `eu-west-1` region.

- Application Load Balancer `cmtr-iacp1ebx-lb`: distributes HTTP traffic between the Blue and Green environments.
- Blue target group `cmtr-iacp1ebx-blue-tg`: receives traffic for the Blue environment.
- Green target group `cmtr-iacp1ebx-green-tg`: receives traffic for the Green environment.
- Blue Auto Scaling group `cmtr-iacp1ebx-blue-asg`: manages the EC2 instances for the Blue environment.
- Green Auto Scaling group `cmtr-iacp1ebx-green-asg`: manages the EC2 instances for the Green environment.
- Blue launch template `cmtr-iacp1ebx-blue-template`: defines the EC2 configuration for the Blue environment.
- Green launch template `cmtr-iacp1ebx-green-template`: defines the EC2 configuration for the Green environment.
- Security group `cmtr-iacp1ebx-sg-ssh`: allows SSH access to instances.
- Security group `cmtr-iacp1ebx-sg-http`: allows HTTP access to instances.
- Security group `cmtr-iacp1ebx-sg-lb`: allows HTTP access to the load balancer.

#### Objectives

Gain an understanding of the next AWS resources [Application Load Balancers (ALB)](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/application-load-balancers.html), [Target Groups](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-target-groups.html), [Launch Templates](https://docs.aws.amazon.com/autoscaling/ec2/userguide/launch-templates.html), [Auto Scaling Groups (ASG)](https://docs.aws.amazon.com/autoscaling/ec2/userguide/auto-scaling-groups.html).

1. Create an Application Load Balancer named `cmtr-iacp1ebx-lb` with an HTTP listener and weighted target groups.
2. Create the Blue target group `cmtr-iacp1ebx-blue-tg` and the Green target group `cmtr-iacp1ebx-green-tg`.
3. Configure weighted routing on the load balancer so traffic can be distributed between the Blue and Green target groups.
4. Create the Blue launch template `cmtr-iacp1ebx-blue-template` and the Green launch template `cmtr-iacp1ebx-green-template`.
5. Configure `user data` in each launch template to install a web server and serve environment-specific content.
6. Make sure the Blue environment page uses a simple heading that displays `Blue Environment` and the Green environment page clearly displays `Green Environment`.
7. Create the Blue Auto Scaling group `cmtr-iacp1ebx-blue-asg` and the Green Auto Scaling group `cmtr-iacp1ebx-green-asg`.
8. Attach each Auto Scaling group to its matching launch template and target group.
9. Define the traffic weight variables `blue_weight` with value `100` and `green_weight` with value `0` in `variables.tf` with descriptions and the `number` type and use them to configure the weighted routing behavior of the load balancer.
10. Tag all created resources appropriately.
11. Validate and format the Terraform configuration, then generate a plan.

Use the following Terraform workflow:

*(El bloque de código con el workflow llegó vacío en el enunciado copiado; se usó el flujo estándar `terraform init`, `terraform fmt`, `terraform validate`, `terraform plan`, `terraform apply`.)*

#### Verification

Use the following checks to verify that your solution is correct:

1. Open the AWS Console and navigate to EC2 Load Balancers. Verify that the Application Load Balancer `cmtr-iacp1ebx-lb` is created and active.
2. Open EC2 Target Groups and confirm that both `cmtr-iacp1ebx-blue-tg` and `cmtr-iacp1ebx-green-tg` exist.
3. Open EC2 Auto Scaling Groups and confirm that both `cmtr-iacp1ebx-blue-asg` and `cmtr-iacp1ebx-green-asg` are created.
4. Verify that the Blue and Green environments each have running EC2 instances registered in their corresponding target groups.
5. Verify that `terraform plan` shows the configuration is valid for the initial traffic split of 100% Blue and 0% Green.
6. Open the ALB DNS name in a browser and confirm that the response shows `Blue Environment` when all traffic is routed to Blue.
7. Update the traffic weights to send part of the traffic to Green and verify that requests can also return `Green Environment`.
8. Confirm that Terraform manages the weighted routing behavior as expected.

Note: Before running task verification:
- Push or update your Terraform configuration in your Git repository.
- Delete the AWS resources you created during the task by running `terraform destroy`.

To pass verification, your repository must contain the final Terraform code, but the deployed resources must already be removed.

**Región:** `eu-west-1` — Cuenta `463470949310`

**Entorno real usado:** código Terraform en este mismo directorio (`02-practica`), corrido localmente vía CLI (Git Bash).

---

## Diseño

- **Descubrimiento de lo pre-creado:** VPC y los dos subnets públicos por tag `Name`; los 3 security groups por nombre; el AMI de Amazon Linux 2023 con `aws_ami` (`most_recent`, dueño y patrón de nombre como variables).
- **Pesos:** `blue_weight` y `green_weight` en `variables.tf` (`number`, con descripción) y sus valores (`100` / `0`) en `terraform.tfvars`. Alimentan los dos bloques `target_group` del `forward` del listener HTTP:80.
- **Entornos:** cada launch template instala `httpd` y escribe su página (`<h1>Blue Environment</h1>` / `<h1>Green Environment</h1>`, el heading viene de una variable); cada ASG referencia su template y su target group (`target_group_arns`).
- Instancias en subnets públicos con IP pública (necesitan salir a internet para `dnf install`).

## Movimiento 1 — Flujo local y apply con 100% Blue

```bash
cd "05-terraform/1.13-aws-iac-with-terraform-implement-blue-green-deployment-with-traffic-routing/02-practica"

terraform init
terraform fmt
terraform validate
terraform plan
terraform apply -auto-approve
```

`apply` creó 8 recursos (2 target groups, 2 launch templates, 2 ASGs, ALB y listener). El plan mostraba los dos `target_group` del `forward` con pesos 100 y 0.

## Movimiento 2 — Pruebas del routing ponderado

```bash
DNS=$(terraform output -raw load_balancer_dns_name)

# 100% Blue
for i in 1 2 3 4 5 6 7 8 9 10; do curl -s http://$DNS; done

# reparto 50/50 (los -var pisan terraform.tfvars solo en ese comando)
terraform apply -auto-approve -var="blue_weight=50" -var="green_weight=50"
aws elbv2 describe-target-health --target-group-arn $(terraform output -raw green_target_group_arn) --query 'TargetHealthDescriptions[].TargetHealth.State'
sleep 45
for i in $(seq 1 20); do curl -s http://$DNS; done | sort | uniq -c

# volver a los valores del repo
terraform apply -auto-approve
terraform plan
```

- **100/0:** las 10 respuestas fueron `Blue Environment`.
- **50/50, primer intento:** las 10 respuestas siguieron siendo `Blue` — se curleó inmediatamente después del `apply`. El cambio de pesos del listener tarda unos segundos en propagarse dentro del ALB aunque Terraform ya haya reportado la modificación como completa (`Modifications complete after 2s`).
- **50/50, segundo intento** (esperando 45 s, con ambos targets `healthy`): 20 respuestas → **10 `Blue` y 10 `Green`**.
- Al volver a 100/0 con `apply`, el `terraform plan` siguiente dio *No changes*: Terraform sigue gestionando los pesos sin deriva.

## Movimiento 3 — Limpieza y push

```bash
terraform destroy -auto-approve
```

8 recursos eliminados (los ASG tardaron ~6 min: terminan sus instancias y los target groups tienen un `deregistration_delay` de 300 s). El código se comiteó y subió **antes** de la verificación.

## Movimiento 4 — Verificación en la plataforma

- **Repository branch:** `main`
- **Repository folder:** `05-terraform/1.13-aws-iac-with-terraform-implement-blue-green-deployment-with-traffic-routing/02-practica`
- **Repository HTTPS URL:** con PAT embebido.

14/14 checks pasados en el primer intento — ver [03-resultados](../03-resultados/README.md). La plataforma replicó las pruebas manuales: con 100/0 detectó solo `Blue Environment`; luego hizo un `apply` cambiando los pesos y detectó solo `Green Environment`.

## Movimiento 5 — Limpieza final

Se usó el botón **"Destroy Resources"** de la plataforma.
