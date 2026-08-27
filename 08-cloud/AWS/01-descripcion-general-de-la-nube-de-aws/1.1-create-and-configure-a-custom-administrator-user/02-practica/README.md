# Práctica — Crear y configurar un usuario administrador personalizado

## Enunciado de la tarea

> Crear y configurar un usuario de IAM personalizado con privilegios de administrador, autenticación multifactor (MFA) y acceso programático a AWS.

**Recurso de la tarea:** Usuario de IAM `${aws_iam_user}` → en mi ejecución: `cmtr-iacp1ebx-user`

**Objetivos (4 movimientos):**
1. Crear un nuevo usuario de IAM con el nombre `${aws_iam_user}`.
2. Adjuntar la política administrada `AdministratorAccess` (existente, no crear una nueva).
3. Configurar MFA usando únicamente "Security key or biometric" o "Authenticator app".
4. Generar un par de claves de acceso para acceso programático vía CLI.

**Verificación:** loguearse en la Consola como el usuario creado y ejecutar cualquier comando que requiera acceso administrativo.

**Entorno real usado:** sandbox temporal de AWS (credenciales STS), cuenta `311141534372`, región `eu-west-1`. Abajo documento ambos caminos posibles (CLI/CloudShell y Consola web) para cada movimiento — en la práctica combiné los dos: usuario/política por CLI, MFA y access key por Consola.

---

## Movimiento 1 — Crear el usuario IAM

### Opción A — CLI / CloudShell
```bash
aws iam create-user --user-name cmtr-iacp1ebx-user
```
```json
{
    "User": {
        "Path": "/",
        "UserName": "cmtr-iacp1ebx-user",
        "UserId": "AIDAUQ4L3BKSNOPAZHGWR",
        "Arn": "arn:aws:iam::311141534372:user/cmtr-iacp1ebx-user",
        "CreateDate": "2026-08-20T12:02:42+00:00"
    }
}
```
> Nota: el CLI de AWS pipea el JSON de salida por un paginador (`less`). Si el terminal parece "colgado" mostrando un `:` al final, es el paginador esperando input — se sale con `q`. Para evitarlo en toda la sesión: `export AWS_PAGER=""`.

### Opción B — Consola web
1. Barra de búsqueda superior → **IAM** → entra al servicio.
2. Menú izquierdo → **Users** → botón **Create user**.
3. En "User name" escribe `cmtr-iacp1ebx-user`.
4. Deja sin marcar "Provide user access to the AWS Management Console" (no es requisito de este movimiento; se habilita más tarde para la verificación final).
5. **Next** → **Create user**.

**Este movimiento lo hice por CLI.**

---

## Movimiento 2 — Adjuntar la política administrada `AdministratorAccess`

### Opción A — CLI / CloudShell
```bash
aws iam attach-user-policy --user-name cmtr-iacp1ebx-user --policy-arn arn:aws:iam::aws:policy/AdministratorAccess
```
Sin salida = éxito. Verificación:
```bash
aws iam list-attached-user-policies --user-name cmtr-iacp1ebx-user
```
```json
{
    "AttachedPolicies": [
        {
            "PolicyName": "AdministratorAccess",
            "PolicyArn": "arn:aws:iam::aws:policy/AdministratorAccess"
        }
    ]
}
```

### Opción B — Consola web
1. Si vienes del flujo de creación: en "Set permissions" selecciona **Attach policies directly**. Si el usuario ya existía: IAM → Users → `cmtr-iacp1ebx-user` → pestaña **Permissions** → **Add permissions** → **Attach policies directly**.
2. En el buscador de políticas escribe `AdministratorAccess`.
3. Marca el checkbox de la política **AdministratorAccess** (ícono naranja "AWS managed") — no usar "Create policy".
4. **Next** → **Add permissions** (o **Create user** si vienes del flujo de creación).

**Este movimiento lo hice por CLI.**

---

## Movimiento 3 — Configurar MFA

### Opción A — CLI (solo viable para "Authenticator app")
La opción "Security key or biometric" usa el protocolo WebAuthn y **no tiene equivalente por CLI** — solo se puede hacer desde el navegador. Para "Authenticator app" sí es posible, aunque más incómodo que por Consola porque hay que descargar y escanear un archivo QR:
```bash
aws iam create-virtual-mfa-device \
  --virtual-mfa-device-name cmtr-iacp1ebx-user-mfa \
  --outfile QRCode.png \
  --bootstrap-method QRCodePNG
```
Esto devuelve el `SerialNumber` del dispositivo y genera `QRCode.png` (en CloudShell: botón **Actions → Download file**). Se escanea con la app autenticadora y se activa con dos códigos consecutivos:
```bash
aws iam enable-mfa-device \
  --user-name cmtr-iacp1ebx-user \
  --serial-number arn:aws:iam::311141534372:mfa/cmtr-iacp1ebx-user-mfa \
  --authentication-code1 CODIGO1 \
  --authentication-code2 CODIGO2
```

### Opción B — Consola web
1. IAM → Users → `cmtr-iacp1ebx-user` → pestaña **Security credentials**.
2. Sección "Multi-factor authentication (MFA)" → **Assign MFA device** → nombre `cmtr-iacp1ebx-user-mfa`.
3. Elige el tipo:
   - **Authenticator app**: escanea el QR con Google Authenticator/Authy/Microsoft Authenticator (o usa "Show secret key" para ingresarlo manualmente) → ingresa **dos códigos consecutivos** (esperando ~30s entre uno y otro) → **Add MFA**.
   - **Security key or biometric**: sigue el flujo de registro WebAuthn del navegador (llave física FIDO2, Windows Hello, Touch ID, passkey, etc.).
4. No usar "Hardware TOTP token" (no permitido por el enunciado).

**Este movimiento lo hice por Consola web** (opción Authenticator app) — más simple que lidiar con la descarga del QR desde CloudShell. Verificación por CLI:
```bash
aws iam list-mfa-devices --user-name cmtr-iacp1ebx-user
```
```json
{
    "MFADevices": [
        {
            "UserName": "cmtr-iacp1ebx-user",
            "SerialNumber": "arn:aws:iam::311141534372:mfa/cmtr-iacp1ebx-user-mfa",
            "EnableDate": "2026-08-20T12:09:07+00:00"
        }
    ]
}
```

---

## Movimiento 4 — Generar claves de acceso programático

### Opción A — CLI / CloudShell
```bash
aws iam create-access-key --user-name cmtr-iacp1ebx-user
```
Devuelve `AccessKeyId` y `SecretAccessKey` — copiarlos de inmediato, el secret no se puede volver a consultar.

### Opción B — Consola web
1. IAM → Users → `cmtr-iacp1ebx-user` → pestaña **Security credentials**.
2. Sección **Access keys** → **Create access key**.
3. Caso de uso: **Command Line Interface (CLI)** → marcar el checkbox de confirmación → **Next**.
4. (Opcional) etiqueta descriptiva → **Create access key**.
5. Copiar/descargar el `.csv` inmediatamente.

**Este movimiento lo hice por Consola web.** Verificación por CLI:
```bash
aws iam list-access-keys --user-name cmtr-iacp1ebx-user
```
```json
{
    "AccessKeyMetadata": [
        {
            "UserName": "cmtr-iacp1ebx-user",
            "AccessKeyId": "AKIAUQ4L3BKSICM4JSHZ",
            "Status": "Active",
            "CreateDate": "2026-08-20T12:10:19+00:00"
        }
    ]
}
```

---

## Verificación final — login como el usuario creado

1. Habilité el acceso a consola con contraseña para `cmtr-iacp1ebx-user` (estaba desactivado por defecto al crear el usuario solo por CLI): IAM → Users → Security credentials → **Enable console access** → contraseña personalizada.
2. Cerré sesión del rol admin del sandbox e inicié sesión como `cmtr-iacp1ebx-user` con Account ID + username + password + código MFA.
3. Intenté abrir **AWS CloudShell** para correr un comando administrativo y me encontré con un error inesperado (ver "Incidente" abajo).
4. Verifiqué en su lugar navegando la Consola (IAM → Users, listado completo visible sin "Access Denied") y confirmé `PasswordLastUsed` poblado en el registro del usuario — evidencia de que el login fue exitoso.

### Incidente: CloudShell bloqueado por una Service Control Policy

Al intentar abrir CloudShell logeado como `cmtr-iacp1ebx-user` (con `AdministratorAccess` adjuntada):

```
Unable to create the environment... User: arn:aws:iam::311141534372:user/cmtr-iacp1ebx-user is not authorized
to perform: cloudshell:CreateEnvironment on resource: * with an explicit deny in a service control policy:
arn:aws:organizations::533267139808:policy/o-j09uu9d646/service_control_policy/p-lh868xkg
```

**Causa**: una SCP a nivel de AWS Organizations bloquea `cloudshell:CreateEnvironment` para toda la cuenta del sandbox — probablemente para evitar abuso de cómputo en cuentas de entrenamiento. Las SCP se evalúan *antes* que cualquier política de IAM y pueden denegar incluso a `AdministratorAccess`, que solo controla el límite superior de lo permitido dentro de la cuenta, no lo que la organización decide bloquear por fuera.

**Lección**: un "Access Denied" no siempre significa que la política de IAM esté mal configurada — hay que revisar si el mensaje menciona explícitamente una *service control policy*, en cuyo caso el problema está a nivel de Organizations, fuera del alcance de lo que se puede arreglar tocando permisos de IAM del usuario.
