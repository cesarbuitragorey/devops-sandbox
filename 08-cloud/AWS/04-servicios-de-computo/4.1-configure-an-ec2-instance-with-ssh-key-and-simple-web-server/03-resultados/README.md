# Resultados — Configure an EC2 Instance with SSH Key and Simple Web Server

**Estado:** ✅ Tarea completada y verificada por la plataforma (9/9 checks aprobados)

## Resumen de los recursos creados

| Recurso | Valor |
|---|---|
| Cuenta | `149536493305` |
| EC2 Instance | `i-0497150c6bada7106` — `running` |
| VPC | `vpc-0a848099b789c18fc` |
| Security Group | `cmtr-iacp1ebx-sg` (`sg-0687bba613b792797`) |
| Key Pair | `cmtr-iacp1ebx-key` (adjunto a la instancia) |
| Instance Profile | `cmtr-iacp1ebx-role` |

## Verificación automática de la plataforma

1. **EC2 creada y en estado `running`** ✅
2. **Security Group `cmtr-iacp1ebx-sg` creado** ✅
3. **Regla de entrada puerto 80/tcp** ✅
4. **Regla de entrada puerto 22/tcp** ✅
5. **Security Group adjunto a la instancia** ✅
6. **Puerto 80 responde `200`** ✅
7. **Key pair `cmtr-iacp1ebx-key` adjunto a la instancia** ✅
8. **Instance profile `cmtr-iacp1ebx-role` creado** ✅
9. **Instance profile adjunto a la instancia** ✅ — `arn:aws:iam::149536493305:instance-profile/cmtr-iacp1ebx-role`

## Recursos destruidos

Al finalizar se usó el botón **"Destroy Resources"** de la plataforma.
