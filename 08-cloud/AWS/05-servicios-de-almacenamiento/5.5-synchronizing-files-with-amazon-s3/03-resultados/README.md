# Resultados — Synchronizing Files with Amazon S3

**Estado:** ✅ Tarea completada y verificada por la plataforma (8/8 checks aprobados)

## Resumen de los recursos configurados

| Recurso | Configuración |
|---|---|
| `cmtr-iacp1ebx-s3-sync-policy` | Customer managed, `ListBucket` + `PutObject`/`GetObject` acotados al bucket primario |
| Bucket primario | Versionado `Enabled`, lifecycle `retain-3-versions` (`NewerNoncurrentVersions: 3`) |
| Bucket secundario | Versionado `Enabled`, lifecycle `retain-5-versions` (`NewerNoncurrentVersions: 5`) |
| Replicación | Primario → Secundario, rol `s3crr_role_for_cmtr-iacp1ebx-s3-s-bucket-297591-backup-primary` |
| Cron job (`ec2-user`) | `* * * * * aws s3 sync /backups s3://...primary >> /home/ec2-user/sync_s3.log 2>&1` |

## Verificación automática de la plataforma

1. **Versionado habilitado en el bucket primario** ✅
2. **Lifecycle del primario retiene 3 versiones** ✅
3. **Versionado habilitado en el bucket secundario** ✅
4. **Lifecycle del secundario retiene 5 versiones** ✅
5. **Replicación configurada correctamente hacia el secundario** ✅
6. **El cron job sincroniza archivos a S3** ✅ — se ve el log real `upload: ../../backups/test1.txt to s3://...`
7. **El instance profile tiene los permisos requeridos** ✅ — `s3:ListBucket`, `s3:PutObject`, `s3:GetObject`
8. **El instance profile NO tiene permisos prohibidos** ✅ — sin `s3:PutBucketPolicy` ni `s3:PutBucketAcl`, confirmando mínimo privilegio

## Recursos destruidos

Al finalizar se usó el botón **"Destroy Resources"** de la plataforma. La política de IAM customer-managed (`cmtr-iacp1ebx-s3-sync-policy`), al haberse creado manualmente por fuera del stack, conviene verificarla/eliminarla aparte si no queda cubierta por el destroy automático.
