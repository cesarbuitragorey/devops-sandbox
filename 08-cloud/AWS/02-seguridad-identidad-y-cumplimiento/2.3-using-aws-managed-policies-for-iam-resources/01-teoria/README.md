# Teoría — AWS Managed Policies para roles de IAM

## AWS managed policies for job functions

AWS mantiene un conjunto de políticas administradas pensadas para mapear directamente a **funciones de trabajo** comunes (job functions), documentadas en [AWS managed policies for job functions](https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies_job-functions.html). La idea es no tener que diseñar desde cero el set de permisos de un "Administrador", un "Facturación", un "Soporte", etc. — AWS ya publica y mantiene esas políticas.

Dos de las más usadas, y las que aplican a este lab:

| Política | Alcance |
|---|---|
| **`AdministratorAccess`** | `Action: "*"` sobre `Resource: "*"` — control total de todos los servicios de la cuenta (salvo lo que una SCP de Organizations deniegue explícitamente). |
| **`ReadOnlyAccess`** | Acciones de lectura/listado/descripción (`Get*`, `List*`, `Describe*`, etc.) en prácticamente todos los servicios de AWS — sin ninguna acción de creación, modificación o eliminación. |

## Por qué usar políticas administradas por AWS en vez de crear las propias

- **Mantenimiento automático**: cuando AWS lanza un servicio o acción nueva, actualiza estas políticas administradas sin que el usuario tenga que hacer nada.
- **Menor riesgo de error humano**: escribir a mano una política JSON con centenares de `Allow` (como requeriría un `AdministratorAccess` o `ReadOnlyAccess` propios) es propenso a errores de sintaxis o permisos de más/de menos.
- **Reusabilidad**: la misma política se puede adjuntar a cualquier rol/usuario/grupo de la cuenta, sin duplicar definiciones.

Es exactamente lo que pide el enunciado de este lab: "Please use existing AWS policies and do not create your own" — mapear cada rol a la política administrada cuyo propósito coincide con el nombre/función del rol.

## Relación con los labs anteriores de este módulo

Este lab es, en esencia, una versión simplificada de los labs 2.1 y 2.2: en vez de configurar herencia de grupo (2.1) o role chaining con trust policies (2.2), aquí el foco es únicamente **elegir la política administrada correcta** para cada rol, sin lógica adicional de confianza entre entidades — cada rol ya viene creado y solo falta darle sus permisos vía `attach-role-policy`.
