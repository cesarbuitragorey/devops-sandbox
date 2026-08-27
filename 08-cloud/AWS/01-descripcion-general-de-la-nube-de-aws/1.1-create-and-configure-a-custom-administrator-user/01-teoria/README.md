# Teoría — IAM: usuario administrador personalizado, MFA y acceso programático

## IAM (Identity and Access Management)

IAM es el servicio de AWS para controlar **quién** (autenticación) puede hacer **qué** (autorización) sobre qué recursos. Entidades principales:

- **Usuarios (Users)**: identidades individuales (personas o aplicaciones) con credenciales propias.
- **Grupos**: colecciones de usuarios a los que se les aplican políticas en conjunto.
- **Roles**: identidades sin credenciales permanentes, pensadas para ser *asumidas* (por otro usuario, un servicio de AWS, o una federación externa) mediante credenciales temporales (STS).
- **Políticas**: documentos JSON que definen permisos (`Allow`/`Deny` sobre acciones y recursos).

## Políticas administradas vs. políticas en línea

- **AWS managed policies** (como `AdministratorAccess`): mantenidas por AWS, reutilizables entre cuentas, no editables directamente. `AdministratorAccess` otorga `Action: "*"` sobre `Resource: "*"` — control total de la cuenta salvo lo que esté explícitamente denegado por una **Service Control Policy (SCP)** a nivel de AWS Organizations (las SCP siempre ganan sobre cualquier política de IAM, incluso `AdministratorAccess`).
- **Customer managed policies**: creadas y versionadas por el usuario, para permisos a medida.
- **Inline policies**: embebidas directamente en un usuario/rol/grupo específico, no reusables.

> Buena práctica real (fuera del contexto de este lab de entrenamiento): aplicar el **principio de menor privilegio** en vez de adjuntar `AdministratorAccess` a usuarios humanos de uso diario. Este lab pide explícitamente esa política porque el objetivo es practicar el flujo de creación de usuario + políticas administradas, no diseñar permisos mínimos.

## MFA (Multi-Factor Authentication)

Añade un segundo factor de autenticación además de la contraseña. Tipos soportados por IAM:

| Tipo | Cómo funciona | Uso típico |
|---|---|---|
| **Virtual MFA / Authenticator app** | Genera códigos TOTP (Time-based One-Time Password) de 6 dígitos cada 30s, a partir de una semilla compartida (QR) | Apps como Google Authenticator, Authy, Microsoft Authenticator |
| **Security key / passkey (FIDO2/WebAuthn)** | Autenticación criptográfica con una llave física o el gestor de credenciales del SO/navegador | YubiKey, Windows Hello, Touch ID, passkeys de navegador |
| **Hardware TOTP token** | Dispositivo físico dedicado que genera códigos TOTP | Poco usado hoy, requiere comprar hardware específico |

Este lab exige usar solo las dos primeras opciones (no hardware TOTP). El dispositivo virtual (Authenticator app) se puede crear vía CLI con `create-virtual-mfa-device` + `enable-mfa-device`, pero requiere escanear un QR o introducir una semilla — en la práctica es más simple hacerlo desde la Consola web. La opción de Security key usa el protocolo **WebAuthn**, que solo funciona en un navegador (no hay equivalente por CLI).

## Acceso programático (Access Keys)

Un par `Access Key ID` + `Secret Access Key` permite autenticar llamadas a la API de AWS (CLI, SDKs) **sin usar contraseña ni MFA en cada llamada**. Son credenciales de larga duración (a diferencia de las credenciales temporales de un rol asumido vía STS, que expiran). El `Secret Access Key` solo se muestra **una vez** al crearlo — si se pierde, hay que rotar la clave (desactivar la vieja, crear una nueva).

## Relación entre las piezas de este lab

1. Usuario IAM = identidad.
2. Política `AdministratorAccess` adjuntada = autorización.
3. MFA = segundo factor para el login por consola (contraseña + código).
4. Access keys = autenticación para acceso programático (CLI/SDK), independiente del MFA de consola.
