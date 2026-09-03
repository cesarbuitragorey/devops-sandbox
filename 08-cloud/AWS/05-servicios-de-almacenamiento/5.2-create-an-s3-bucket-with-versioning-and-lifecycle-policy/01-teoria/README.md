# Teoría — S3 Versioning y Lifecycle Policies

## Versionado de S3

Con el versionado habilitado en un bucket, cada `PUT` sobre una misma `Key` no sobrescribe el objeto anterior — crea una **nueva versión**, y la anterior pasa a ser una **"noncurrent version"** (versión no vigente), pero sigue existiendo y ocupando espacio/costo hasta que se elimine explícitamente. Esto protege contra sobrescrituras/borrados accidentales (se puede restaurar cualquier versión anterior), pero sin gestión activa, el bucket acumula versiones viejas indefinidamente, incrementando el costo de almacenamiento con el tiempo.

## Lifecycle Rules — gestión automática del ciclo de vida

Una **Lifecycle Rule** automatiza acciones sobre los objetos de un bucket según su antigüedad, sin intervención manual. Dos tipos de acciones relevantes en este lab, ambas aplicadas específicamente sobre **versiones no vigentes** (`Noncurrent*`, no sobre la versión actual del objeto):

- **`NoncurrentVersionTransitions`**: mueve una versión no vigente a una clase de almacenamiento más barata después de N días desde que dejó de ser la versión actual.
- **`NoncurrentVersionExpiration`**: elimina permanentemente una versión no vigente después de N días.

## Clases de almacenamiento: por qué Standard-IA para versiones viejas

**S3 Standard-IA** ("Infrequent Access") ofrece el mismo nivel de durabilidad que Standard, con un costo de almacenamiento por GB más bajo, a cambio de un cargo por recuperación (retrieval) cuando sí se necesita leer el dato. Es ideal para versiones no vigentes: se mantienen disponibles por si hace falta recuperarlas, pero es improbable que se accedan con frecuencia (la versión "activa" del objeto es la que normalmente se consulta) — así se reduce el costo de mantener el historial de versiones sin perder la capacidad de recuperación.

## La secuencia temporal de este lab

```
Día 0: se sobrescribe/borra un objeto → la versión anterior pasa a "noncurrent"
Día 30: esa versión noncurrent se mueve a Standard-IA (más barata)
Día 50: esa versión noncurrent se elimina permanentemente
```

Nótese que estos contadores se miden desde el momento en que la versión **dejó de ser la actual** (no desde su fecha de creación original) — una versión puede vivir mucho tiempo como "current" antes de empezar a contar los 30/50 días de esta regla.
