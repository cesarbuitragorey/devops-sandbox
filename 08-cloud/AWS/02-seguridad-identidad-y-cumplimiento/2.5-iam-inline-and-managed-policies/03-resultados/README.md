# Resultados — IAM Inline and Managed Policies

**Estado:** ✅ Tarea completada y verificada por la plataforma (11/11 checks aprobados)

## Resumen de los recursos configurados

| Recurso | Configuración |
|---|---|
| `cmtr-iacp1ebx-iam-iamp-iam_policy-managed` | Versión `v3` (default) con `sts:AssumeRole`, `s3:ListAllMyBuckets`, `s3:ListBucket`, `iam:ListRoles`, `iam:ListUsers` |
| `cmtr-iacp1ebx-iam-iamp-user` | Política managed adjuntada |
| `cmtr-iacp1ebx-iam-iamp-iam_role-managed` | Política managed adjuntada |
| `cmtr-iacp1ebx-iam-iamp-iam_role-inline` | Política inline `s3-list-inline-policy` (`s3:ListAllMyBuckets`, `s3:ListBucket`) — **sin** la política managed |

## Verificación automática de la plataforma

1. **Política inline correctamente adjunta al rol inline** ✅
2. **El rol inline NO tiene la política managed** ✅ — confirma que ambas identidades quedaron correctamente separadas (managed vs. inline)
3. **Política managed adjunta al usuario** ✅
4. **Política managed adjunta al rol managed** ✅
5. **Acceso a S3 concedido por la política managed** ✅
6. **`iam:ListRoles` funciona desde la política managed** ✅ — devuelve el listado completo de roles de la cuenta
7. **`iam:ListUsers` funciona desde la política managed** ✅
8. **`iam:ListGroups` correctamente DENEGADO en el rol managed** ✅ — `AccessDenied` (no se otorgó ese permiso, confirma que solo se dieron los 5 permisos pedidos, ni uno más)
9. **Acceso a S3 concedido por la política inline** ✅
10. **`iam:ListGroups` correctamente DENEGADO en el rol inline** ✅ — mismo control de mínimo privilegio que en el rol managed
11. **Bono por uso de CLI** ✅ — coeficiente 1.0

Los checks 8 y 10 son la prueba de mínimo privilegio del lab: verifican que ninguna de las dos políticas otorgó permisos de más allá de los explícitamente pedidos (`iam:ListGroups` nunca estuvo en el enunciado, y efectivamente está denegado en ambos roles).

## Recursos destruidos

Al finalizar se usó el botón **"Destroy Resources"** de la plataforma — el usuario, los roles y las políticas configuradas ya no existen fuera de este registro.
