# Resultados — Create and Configure Your Own VPC

**Estado:** ✅ Tarea completada y verificada por la plataforma (11/11 checks aprobados)

## Resumen de los recursos creados

| Recurso | ID | Detalle |
|---|---|---|
| VPC | `vpc-002c26e7c4bc81eac` | `10.0.0.0/16` |
| Public Subnet | `subnet-02c9ec1b2284db303` | `10.0.1.0/24`, AZ `eu-west-1a` |
| Private Subnet | `subnet-0cbfeb74e8b6d79df` | `10.0.2.0/24`, AZ `eu-west-1a` |
| Internet Gateway | `igw-09bef7d23ed7c92b7` | Adjunto a la VPC |
| Route Table pública | `rtb-085f4f8afdd365c1d` | `0.0.0.0/0 -> igw-...`, asociada a la subred pública |
| Route Table privada | `rtb-0188a4aae1e9addf2` | Solo ruta `local`, asociada a la subred privada |
| EC2 pública | `i-0cedf46be32cbc9b9` | `10.0.1.104` / IP pública `54.194.106.136`, `default` SG, instance profile SSM, nginx corriendo |
| EC2 privada | `i-09a7c370b9e5e73ed` | `10.0.2.230`, sin IP pública, `default` SG |
| Instance Profile | `cmtr-iacp1ebx-ssm-instance-profile` | Rol con `AmazonSSMManagedInstanceCore` |

## Verificación automática de la plataforma

1. **VPC con CIDR correcto** ✅
2. **Subred pública con CIDR y VPC correctos** ✅
3. **Subred privada con CIDR y VPC correctos** ✅
4. **Internet Gateway creado y adjunto** ✅
5. **Route table pública asociada + ruta a IGW** ✅ (incluye la ruta `local` automática y la `0.0.0.0/0`)
6. **Route table privada asociada, sin ruta a internet** ✅ (solo ruta `local`)
7. **EC2 pública correctamente configurada** ✅ — `t3.micro`, subred correcta, SG `default`, estado `running`
8. **EC2 privada correctamente configurada** ✅ — mismo detalle, sin IP pública
9. **nginx respondiendo en la instancia pública** ✅
10. **Instancia pública con acceso a internet** ✅ — `0% packet loss` a `8.8.8.8`
11. **Instancia pública con conectividad a la instancia privada** ✅ — `0% packet loss` a `10.0.2.230`

## Recursos destruidos

Al finalizar se usó el botón **"Destroy Resources"** de la plataforma para los recursos de red/EC2. El rol y el instance profile de SSM (`cmtr-iacp1ebx-ssm-role` / `cmtr-iacp1ebx-ssm-instance-profile`), al haber sido creados manualmente por fuera del stack de la tarea, se eliminaron aparte:
```bash
aws iam remove-role-from-instance-profile --instance-profile-name cmtr-iacp1ebx-ssm-instance-profile --role-name cmtr-iacp1ebx-ssm-role
aws iam delete-instance-profile --instance-profile-name cmtr-iacp1ebx-ssm-instance-profile
aws iam detach-role-policy --role-name cmtr-iacp1ebx-ssm-role --policy-arn arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore
aws iam delete-role --role-name cmtr-iacp1ebx-ssm-role
```
