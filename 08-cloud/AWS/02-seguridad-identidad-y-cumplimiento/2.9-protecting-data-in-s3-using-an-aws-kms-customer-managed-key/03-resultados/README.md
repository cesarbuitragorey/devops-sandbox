# Resultados — Protecting Data in S3 Using an AWS KMS Customer Managed Key

**Estado:** ✅ Tarea completada y verificada por la plataforma (4/4 checks aprobados)

## Resumen de los recursos configurados

| Recurso | Configuración |
|---|---|
| `cmtr-iacp1ebx-iam-sewk-iam_role` | Política inline `kms-key-access-policy` (Encrypt/Decrypt/ReEncrypt/GenerateDataKey/DescribeKey) acotada al ARN de la key |
| `cmtr-iacp1ebx-iam-sewk-bucket-9899147-2` | Cifrado por defecto SSE-KMS con la key `a2188234-dfd1-4004-9424-ae693adb1051`, `BucketKeyEnabled: true` |
| `confidential_credentials.csv` | Copiado desde el bucket 1, cifrado correctamente con la key indicada |

## Verificación automática de la plataforma

1. **Bucket cifrado con la KMS key correcta** ✅ — `SSEAlgorithm: aws:kms`, `KMSMasterKeyID` coincide
2. **Objeto cifrado con la key correcta** ✅ — `SSEKMSKeyId` coincide exactamente
3. **Cifrar con OTRA key está bloqueado** ✅ — `AccessDenied ... with an explicit deny in a resource-based policy` (restricción preexistente del bucket, no configurada por nosotros)
4. **Bono por uso de CLI** ✅ — coeficiente 1.0

## Recursos destruidos

Al finalizar se usó el botón **"Destroy Resources"** de la plataforma — el rol, los buckets y la key configurados ya no existen fuera de este registro.
