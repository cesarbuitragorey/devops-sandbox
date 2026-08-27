# Práctica — Configuración de los permisos del grupo IAM

## Enunciado de la tarea

> Configurar los permisos necesarios para un grupo de usuarios determinado y verificar que los usuarios de dicho grupo hayan heredado estos permisos.

**Región:** `eu-west-1`

**Recursos de la tarea** (ya provisionados por el sandbox, no hay que crearlos):
- Grupo IAM `${group_developers}` → en mi ejecución: `cmtr-iacp1ebx-iam-g-group-developers`
- Usuarios `${user_dev_0}`, `${user_dev_1}`, `${user_dev_2}` → `cmtr-iacp1ebx-iam-g-user-dev-0/1/2`, ya agregados al grupo

**Objetivo (1 solo movimiento):** otorgar al grupo acceso completo a EC2 usando una política administrada por AWS, siguiendo mínimo privilegio (no crear política propia).

**Entorno real usado:** sandbox AWS con credenciales STS temporales, cuenta `423623856894`. Trabajé por **CLI** (CloudShell).

---

## Movimiento único — Adjuntar `AmazonEC2FullAccess` al grupo

### Opción A — CLI / CloudShell
```bash
aws iam attach-group-policy \
  --group-name cmtr-iacp1ebx-iam-g-group-developers \
  --policy-arn arn:aws:iam::aws:policy/AmazonEC2FullAccess \
  --region eu-west-1
```
Sin salida = éxito. Verificación:
```bash
aws iam list-attached-group-policies --group-name cmtr-iacp1ebx-iam-g-group-developers
```
```json
{
    "AttachedPolicies": [
        {
            "PolicyName": "AmazonEC2FullAccess",
            "PolicyArn": "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
        }
    ]
}
```

Confirmación de que los 3 usuarios pertenecen al grupo:
```bash
aws iam get-group --group-name cmtr-iacp1ebx-iam-g-group-developers
```
```json
{
    "Users": [
        {"UserName": "cmtr-iacp1ebx-iam-g-user-dev-2", "Arn": "arn:aws:iam::423623856894:user/cmtr-iacp1ebx-iam-g-user-dev-2", ...},
        {"UserName": "cmtr-iacp1ebx-iam-g-user-dev-1", "Arn": "arn:aws:iam::423623856894:user/cmtr-iacp1ebx-iam-g-user-dev-1", ...},
        {"UserName": "cmtr-iacp1ebx-iam-g-user-dev-0", "Arn": "arn:aws:iam::423623856894:user/cmtr-iacp1ebx-iam-g-user-dev-0", ...}
    ],
    "Group": {"GroupName": "cmtr-iacp1ebx-iam-g-group-developers", "Arn": "arn:aws:iam::423623856894:group/users/cmtr-iacp1ebx-iam-g-group-developers", ...}
}
```

### Opción B — Consola web
1. Barra de búsqueda → **IAM** → menú izquierdo → **User groups**.
2. Clic en `cmtr-iacp1ebx-iam-g-group-developers`.
3. Pestaña **Permissions** → **Add permissions** → **Attach policies**.
4. Buscar `AmazonEC2FullAccess` en las políticas administradas por AWS → marcar el checkbox.
5. **Add permissions**.

---

## Verificación — login como uno de los usuarios del grupo

### 1. Crear contraseña de consola para el usuario
```bash
aws iam create-login-profile \
  --user-name cmtr-iacp1ebx-iam-g-user-dev-0 \
  --password TuPassword123 \
  --no-password-reset-required
```

### 2. Login y prueba de acceso a EC2
- URL directa (evita escribir mal el Account ID): `https://423623856894.signin.aws.amazon.com/console`
- Pestaña **IAM user** → usuario `cmtr-iacp1ebx-iam-g-user-dev-0` → password recién creada.
- Recomendado usar ventana de incógnito para no chocar con la sesión admin del sandbox en el mismo navegador.
- Ya logeado: entrar a **EC2** en la consola (o `aws ec2 describe-instances`) — debe funcionar sin error de permisos.

### Incidente: `create-login-profile` "silencioso" y `update-login-profile` fallando con `NoSuchEntity`

Al intentar loguearme por primera vez con una contraseña que creí haber configurado, la consola devolvió `Authentication failed`. Intenté "arreglarlo" con:
```bash
aws iam update-login-profile --user-name cmtr-iacp1ebx-iam-g-user-dev-0 --password TuPassword123 --no-password-reset-required
```
```
An error occurred (NoSuchEntity) when calling the UpdateLoginProfile operation:
Login Profile for User cmtr-iacp1ebx-iam-g-user-dev-0 cannot be found.
```

Esto reveló que el login profile **nunca se había creado realmente** en el intento anterior (aunque en su momento no pareció arrojar ningún error visible). La solución fue simplemente usar `create-login-profile` (no `update`) sobre un usuario que aún no tiene perfil de login:
```bash
aws iam create-login-profile --user-name cmtr-iacp1ebx-iam-g-user-dev-0 --password TuPassword123 --no-password-reset-required
```
```json
{
    "LoginProfile": {
        "UserName": "cmtr-iacp1ebx-iam-g-user-dev-0",
        "CreateDate": "2026-08-24T12:09:57+00:00",
        "PasswordResetRequired": false
    }
}
```
Tras esto el login funcionó normalmente.

**Lección**: `create-login-profile` y `update-login-profile` son mutuamente excluyentes según si el usuario ya tiene o no un perfil de login — `NoSuchEntity` en un `update` es la señal inequívoca de que hay que usar `create` en su lugar, sin necesidad de andar adivinando si el problema fue la contraseña, el usuario o el account ID.
