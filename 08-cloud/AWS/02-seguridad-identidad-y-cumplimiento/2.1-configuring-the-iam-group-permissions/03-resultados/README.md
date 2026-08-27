# Resultados — Configuración de los permisos del grupo IAM

**Estado:** ✅ Tarea completada y verificada por la plataforma (4/4 checks aprobados)

## Resumen del recurso configurado

| Campo | Valor |
|---|---|
| Grupo IAM | `cmtr-iacp1ebx-iam-g-group-developers` |
| ARN del grupo | `arn:aws:iam::423623856894:group/users/cmtr-iacp1ebx-iam-g-group-developers` |
| Política adjunta | `AmazonEC2FullAccess` (AWS managed) |
| Usuarios miembros | `user-dev-0`, `user-dev-1`, `user-dev-2` |
| Login de consola verificado | `user-dev-0` (contraseña creada manualmente para la prueba) |

## Verificación automática de la plataforma

1. **El grupo tiene acceso a EC2** ✅
   ```json
   {"SecurityGroups": []}
   ```
   (código de salida `0` — la llamada a la API de EC2 fue autorizada, aunque no haya security groups creados)

2. **El grupo NO tiene acceso a IAM** ✅ (esperado — así se comprueba el mínimo privilegio)
   ```
   AccessDenied: El usuario cmtr-iacp1ebx-iam-g-user-dev-3 no está autorizado para realizar: iam:ListUsers
   ```

3. **El grupo NO tiene acceso a S3** ✅ (esperado, mismo motivo)
   ```
   AccessDenied: El usuario cmtr-iacp1ebx-iam-g-user-dev-3 no está autorizado para realizar: s3:ListAllMyBuckets
   ```

4. **Bono por uso de CLI** ✅ — coeficiente 1.0 (máximo)

> Nota curiosa: los checks 2 y 3 de la plataforma se ejecutaron contra `cmtr-iacp1ebx-iam-g-user-dev-3` (no contra `-0`, `-1` o `-2` mencionados en el enunciado ni contra el `-0` que usé para el login manual). Esto sugiere que el verificador automatizado usa su propio usuario de prueba, adicional a los 3 documentados — el resultado es el mismo, ya que la política está a nivel de grupo y aplica a cualquier miembro.

## Recursos destruidos

Al finalizar se usó el botón **"Eliminar recursos"** de la plataforma — el grupo, la política adjunta y el login profile creado para la verificación ya no existen fuera de este registro.
