# Teoría — Delete Markers y restauración de objetos en S3

## Qué pasa realmente al "borrar" un objeto en un bucket versionado

En un bucket **sin** versionado, `DeleteObject` borra el dato de forma permanente e irrecuperable. En un bucket **con** versionado habilitado, un `DELETE` sin especificar `--version-id` **no borra ningún dato** — en su lugar, S3 crea una nueva versión especial llamada **delete marker**, que se convierte en la versión "actual" (`IsLatest: true`) del objeto. Como el delete marker no tiene contenido, cualquier operación normal (`GET`, `aws s3 ls`, etc.) sobre esa key deja de mostrar el objeto — parece borrado — pero todas las versiones anteriores, incluyendo la última con contenido real, siguen existiendo intactas en el bucket.

## Restaurar un objeto "borrado": borrar el delete marker, no subir nada

La forma correcta de deshacer un borrado accidental en un bucket versionado es **eliminar el delete marker específico** (usando `delete-object` con el `--version-id` exacto del delete marker, no de la key sin especificar versión). Al desaparecer el delete marker, la versión de contenido inmediatamente anterior vuelve a ser la "actual", y el objeto reaparece exactamente como estaba — mismo contenido, mismo `ETag`, mismo `LastModified` original. Esto es explícitamente lo que pedía este lab: **restaurar sin subir ningún archivo nuevo**.

## `list-object-versions`: dos listas separadas

El comando `aws s3api list-object-versions` devuelve dos colecciones distintas para una misma key:
- **`Versions`**: las versiones con contenido real (incluye objetos actuales y no vigentes).
- **`DeleteMarkers`**: los delete markers — cada uno también tiene su propio `VersionId` único, que se puede borrar como si fuera una versión más.

Un detalle notado en este lab: la versión con contenido apareció con `"VersionId": "null"` (el string literal `"null"`, no ausencia de valor) — esto ocurre cuando un objeto se subió a un bucket **antes** de habilitar el versionado, o mediante alguna operación que no generó un ID de versión real; S3 lo trata como una versión válida más, simplemente con ese identificador especial.

## Por qué el check "no delete markers" es relevante

Que la plataforma valide explícitamente `"no hay delete markers"` (además de "el archivo existe") confirma que la solución esperada era **borrar el delete marker**, y no, por ejemplo, copiar el contenido de la versión vieja a una nueva versión (`copy-object` de la versión antigua sobre la misma key) — esa alternativa también "restauraría" el archivo visualmente, pero dejaría el delete marker viejo enterrado en el historial de versiones, en vez de eliminarlo.
