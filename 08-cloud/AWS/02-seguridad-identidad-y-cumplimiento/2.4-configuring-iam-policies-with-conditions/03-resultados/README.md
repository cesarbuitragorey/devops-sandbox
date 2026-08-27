# Resultados — Configuring IAM Policies With Conditions

**Estado:** ✅ Tarea completada y verificada por la plataforma (14/14 checks aprobados)

## Resumen de los recursos configurados

| Política inline | Rol | Efecto |
|---|---|---|
| `deny-s3-policy` | `cmtr-iacp1ebx-iam-c-iam_role` | Deny `s3:Get*`/`s3:List*` sobre `Resource: "*"` si `aws:SourceIp = 3.250.77.53/32` |
| `deny-ec2-policy` | `cmtr-iacp1ebx-iam-c-iam_role` | Deny `ec2:Describe*` sobre `Resource: "*"` si `aws:RequestedRegion = eu-west-1` |

## Verificación automática de la plataforma (checks destacados)

1. **Ambas políticas son inline, no managed** ✅ (`2` políticas inline detectadas)
2. **Deny `s3:Get*` funciona** ✅ — `AccessDenied` en `GetBucketWebsite`
3. **El rol asumido en la EC2 es el correcto** ✅ — `cmtr-iacp1ebx-iam-c-iam_role`
4-7. **Política de S3 tiene el `SourceIp`, el `Deny`, `s3:Get*` y `s3:List*` correctos** ✅
8. **Deny por región `eu-west-1` funciona** ✅ — `UnauthorizedOperation` en `DescribeInstances`
9. **Acciones EC2 en OTRA región (`us-east-1`) siguen permitidas** ✅ — confirma que el deny está bien acotado solo a `eu-west-1`, no a todo EC2
10. **Deny `s3:List*` a nivel de servicio funciona** ✅ — `AccessDenied` en `ListBuckets` (tras el fix de `Resource: "*"`)
11-13. **Política de EC2 tiene el `Deny`, `ec2:Describe*` y la región `eu-west-1` correctos** ✅
14. **Bono por uso de CLI** ✅ — coeficiente 1.0

## Recursos destruidos

Al finalizar se usó el botón **"Destroy Resources"** de la plataforma — la instancia, el rol, el bucket y las políticas inline ya no existen fuera de este registro.
