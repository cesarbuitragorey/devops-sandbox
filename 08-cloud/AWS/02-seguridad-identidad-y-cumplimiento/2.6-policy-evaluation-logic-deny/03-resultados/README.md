# Resultados — Policy Evaluation Logic (Deny)

**Estado:** ✅ Tarea completada y verificada por la plataforma (11/11 checks aprobados)

## Resumen de los recursos configurados

| Recurso | Configuración |
|---|---|
| `cmtr-iacp1ebx-iam-peld-iam_role` | Identity-based policy: `AmazonS3FullAccess` (AWS managed) |
| `cmtr-iacp1ebx-iam-peld-bucket-7484718` | Resource-based policy ampliada con `Deny s3:DeleteObject` / `s3:DeleteObjectVersion` para ese rol, coexistiendo con el `Allow s3:DeleteObject` preexistente |

## Verificación automática de la plataforma

1. **Política adjunta al rol** ✅
2. **Política del bucket contiene el `Deny` correcto** ✅ (Principal, Action y Resource exactos)
3. **El rol puede listar buckets S3** ✅ (confirma que `AmazonS3FullAccess` sí quedó activo)
4. **El rol puede listar contenido del bucket** ✅
5. **El rol puede subir objetos (`put-object`)** ✅ — el Deny es específico de `DeleteObject`/`DeleteObjectVersion`, no de todo S3
6. **El rol puede copiar archivos al bucket** ✅
7. **El rol NO puede borrar objetos** ✅ — `AccessDenied ... with an explicit deny in a resource-based policy` (la prueba central del lab)
8. **Sin acceso a EC2** ✅ (`UnauthorizedOperation`, mínimo privilegio — `AmazonS3FullAccess` no se filtra a otros servicios)
9. **Sin acceso a SNS** ✅ (`AuthorizationError`)
10. **Sin acceso a Lambda** ✅ (`AccessDeniedException`)
11. **Bono por uso de CLI** ✅ — coeficiente 1.0

Los checks 5, 6 y 8-10 confirman que el bloqueo fue **quirúrgico**: solo se denegaron las acciones de borrado sobre ese bucket específico, sin afectar el resto de permisos de S3 (subir, listar, copiar) ni filtrarse a otros servicios.

## Recursos destruidos

Al finalizar se usó el botón **"Destroy Resources"** de la plataforma — el rol y el bucket configurados ya no existen fuera de este registro.
