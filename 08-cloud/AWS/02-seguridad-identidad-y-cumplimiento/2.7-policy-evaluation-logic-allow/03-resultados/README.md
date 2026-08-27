# Resultados — Policy Evaluation Logic (Allow)

**Estado:** ✅ Tarea completada y verificada por la plataforma (10/10 checks aprobados)

## Resumen de los recursos configurados

| Recurso | Configuración |
|---|---|
| `cmtr-iacp1ebx-iam-pela-iam_role` | Política inline `list-all-buckets-policy` (`s3:ListAllMyBuckets`, `Resource: "*"`) |
| `cmtr-iacp1ebx-iam-pela-bucket-1-7415380` | Bucket policy nueva: `Allow` de `GetObject`/`PutObject`/`ListBucket`, `Principal` acotado al rol |
| `cmtr-iacp1ebx-iam-pela-bucket-2-7415380` | Sin cambios (como pedía el enunciado) |

## Verificación automática de la plataforma

1. **Política inline agregada al rol** ✅
2. **Política del bucket 1 con el `Allow`, `Principal` y `Resource` correctos** ✅
3. **`s3:ListAllMyBuckets` funciona** ✅ — devuelve ambos buckets
4. **`s3:ListBucket` funciona en bucket 1** ✅ — devuelve `image.png`
5. **`s3:GetObject` funciona en bucket 1** ✅
6. **`s3:PutObject` funciona en bucket 1** ✅
7. **`s3:PutObjectAcl` correctamente DENEGADO en bucket 1** ✅ — mínimo privilegio: no se pidió ese permiso y no se otorgó, aunque sea el mismo bucket
8. **`s3:GetBucketTagging` correctamente DENEGADO en bucket 1** ✅ — mismo motivo
9. **Sin acceso al bucket 2** ✅ — `AccessDenied` en `ListObjectsV2`, por ausencia de Allow (no por un Deny)
10. **Bono por uso de CLI** ✅ — coeficiente 1.0

Los checks 7 y 8 son la prueba de que el Allow fue **exacto** en sus acciones (no se usó un wildcard como `s3:*` que hubiera colado permisos de más), y el check 9 es la prueba central del lab: el aislamiento del bucket 2 se logró solo por alcance de `Resource`, sin necesidad de ningún `Deny` explícito.

## Recursos destruidos

Al finalizar se usó el botón **"Destroy Resources"** de la plataforma — el rol y ambos buckets configurados ya no existen fuera de este registro.
