# Resultados — Configure an EFS and Attach It to Two EC2 Instances

**Estado:** ✅ Tarea completada y verificada por la plataforma (7/7 checks aprobados)

## Resumen de los recursos creados

| Recurso | Valor |
|---|---|
| EFS | `fs-0119f8e1c5d26168d` |
| Mount target `eu-west-1a` | `10.0.1.92` (subnet-020ddfcb90638e6c6) |
| Mount target `eu-west-1b` | `10.0.3.79` (subnet-0b81c826e6ff494b5) |
| EC2 instance1 | `i-0c3298a2cf2b3b6ba` (`eu-west-1a`) |
| EC2 instance2 | `i-06658937b7d89c4bf` (`eu-west-1b`) |
| Security Group EFS | `sg-0149d15be40d911eb` — TCP 2049 desde `10.0.0.0/16` |

## Verificación automática de la plataforma

1. **Instancia 1 creada y `running`** ✅
2. **Instancia 2 creada y `running`** ✅
3. **SG de EFS con regla de entrada TCP/2049** ✅
4. **EFS montado en instancia 1** ✅ — `10.0.1.92:/ nfs4 8.0E 0 8.0E 0% /mnt/efs`
5. **EFS montado en instancia 2** ✅ — `10.0.3.79:/ nfs4 8.0E 0 8.0E 0% /mnt/efs`
6. **`test-file.txt` existe en `/mnt/efs` de la instancia 1** ✅
7. **`test-file.txt` existe en `/mnt/efs` de la instancia 2** ✅ — mismo archivo, mismo tamaño (14 bytes), mismo timestamp que en la instancia 1, confirmando que es el mismo dato compartido vía EFS

## Recursos destruidos

Al finalizar se usó el botón **"Destroy Resources"** de la plataforma para los recursos del sandbox. El rol/instance profile de IAM (`cmtr-iacp1ebx-role`), al haber sido creado manualmente, conviene verificarlo/eliminarlo aparte si no queda cubierto por el destroy automático.
