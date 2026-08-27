# Teoría — Políticas Inline vs. Administradas por el Cliente (Customer Managed)

## Los tres tipos de políticas de identidad en IAM

| Tipo | Reusable entre entidades | Versionado | Dónde vive |
|---|---|---|---|
| **AWS managed** | Sí (global, mantenida por AWS) | Sí, AWS la actualiza | Cuenta de AWS (compartida por todos) |
| **Customer managed** | Sí (dentro de tu cuenta) | Sí, hasta 5 versiones, tú decides cuál es la activa | Tu cuenta, como objeto independiente con su propio ARN |
| **Inline** | No — vive embebida en una sola identidad | No tiene versiones | Directamente dentro del usuario/rol/grupo específico |

Este lab usa los tres conceptos deliberadamente en un mismo ejercicio: una política **customer managed** que se reutiliza en dos identidades distintas (un usuario y un rol), y una política **inline** que solo aplica a un tercer rol.

## Customer Managed Policies — versionado

Una política administrada por el cliente no se "edita" en el sentido tradicional: cada cambio de contenido crea una **nueva versión** (`v1`, `v2`, `v3`...) mediante `create-policy-version`. Solo una versión puede estar marcada como **default** (activa) a la vez — el parámetro `--set-as-default` decide cuál rige. Sin ese flag, la versión se crea pero permanece inactiva y las identidades que tengan la política adjunta seguirán usando la versión anterior. IAM limita a un máximo de 5 versiones guardadas por política; al llegar al límite hay que borrar alguna vieja (`delete-policy-version`) antes de poder crear una nueva.

## Cuándo usar inline vs. customer managed

- **Inline**: cuando el permiso es específico y exclusivo de una sola identidad, sin intención de reutilizarlo — se borra automáticamente si se borra la identidad (no queda "huérfana").
- **Customer managed**: cuando el mismo conjunto de permisos aplica a múltiples usuarios/roles/grupos — un solo cambio en la política se refleja en todas las identidades que la tengan adjunta, sin tener que tocarlas una por una.

Este lab ilustra exactamente esa diferencia: la política managed se comparte entre un usuario y un rol (mismos permisos, una sola fuente de verdad), mientras que el rol "inline" tiene un subconjunto de esos mismos permisos definido de forma exclusiva para él.

## Acciones usadas en este lab

| Acción | Qué permite |
|---|---|
| `sts:AssumeRole` | Asumir otros roles (permiso base para role chaining/delegación) |
| `s3:ListAllMyBuckets` | Listar todos los buckets S3 de la cuenta |
| `s3:ListBucket` | Listar el contenido (objetos) de un bucket específico |
| `iam:ListRoles` | Listar todos los roles de IAM de la cuenta |
| `iam:ListUsers` | Listar todos los usuarios de IAM de la cuenta |
