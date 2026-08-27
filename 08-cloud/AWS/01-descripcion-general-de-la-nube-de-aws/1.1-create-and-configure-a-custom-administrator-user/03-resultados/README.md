# Resultados — Usuario administrador personalizado

**Estado:** ✅ Tarea completada y verificada por la plataforma (4/4 checks aprobados)

## Resumen del recurso creado

| Campo | Valor |
|---|---|
| Usuario IAM | `cmtr-iacp1ebx-user` |
| ARN | `arn:aws:iam::311141534372:user/cmtr-iacp1ebx-user` |
| Política adjunta | `AdministratorAccess` (AWS managed) |
| MFA | Authenticator app — `arn:aws:iam::311141534372:mfa/cmtr-iacp1ebx-user-mfa` |
| Access Key | `AKIAUQ4L3BKSICM4JSHZ` — `Active` |
| Login por consola verificado | Sí (`PasswordLastUsed` registrado tras el login de prueba) |

## Verificación automática de la plataforma

1. **Nombre de usuario correcto** ✅
   ```json
   {"Users": [{"Arn": "arn:aws:iam::311141534372:user/cmtr-iacp1ebx-user", "UserName": "cmtr-iacp1ebx-user", "PasswordLastUsed": "2026-08-20T12:15:38+00:00", ...}]}
   ```
2. **MFA activado** ✅
   ```json
   {"MFADevices": [{"SerialNumber": "arn:aws:iam::311141534372:mfa/cmtr-iacp1ebx-user-mfa", "UserName": "cmtr-iacp1ebx-user", "EnableDate": "2026-08-20T12:09:07+00:00"}]}
   ```
3. **Access key creada y activa** ✅
   ```json
   {"AccessKeyMetadata": [{"AccessKeyId": "AKIAUQ4L3BKSICM4JSHZ", "Status": "Active", "UserName": "cmtr-iacp1ebx-user"}]}
   ```
4. **Política de administrador adjuntada** ✅
   ```json
   {"AttachedPolicies": [{"PolicyName": "AdministratorAccess", "PolicyArn": "arn:aws:iam::aws:policy/AdministratorAccess"}]}
   ```

## Recursos destruidos

Al finalizar la tarea se usó el botón **"Destruir recursos"** de la plataforma para liberar el sandbox — el usuario, política, MFA y claves de acceso mostrados arriba ya no existen fuera de este registro.
