# Práctica — Restoring File in S3 Bucket Using AWS S3 Bucket Versioning

## Enunciado de la tarea

> Restore an accidentally deleted file from the S3 bucket using AWS S3 bucket versioning. Do not upload any files.

**Región:** `eu-west-1`

**Recursos de la tarea:**
- Bucket `cmtr-iacp1ebx-s3-rfuv-bucket-822472` (versionado, trabajar **solo** con este bucket)
- Archivo a restaurar: `accidentally_deleted_file.csv`

**Entorno real usado:** sandbox AWS, trabajado por **CLI** en CloudShell.

---

## Paso 1 — Localizar el delete marker

```bash
aws s3api list-object-versions \
  --bucket cmtr-iacp1ebx-s3-rfuv-bucket-822472 \
  --prefix accidentally_deleted_file.csv \
  --region eu-west-1
```

Resultado relevante:
```json
"Versions": [
  {
    "Key": "accidentally_deleted_file.csv",
    "VersionId": "null",
    "IsLatest": false,
    "Size": 38,
    "LastModified": "2026-09-03T11:25:48+00:00"
  }
],
"DeleteMarkers": [
  {
    "Key": "accidentally_deleted_file.csv",
    "VersionId": "3VJUr3cRwlvWHhZRrc7VyF2pqrBOeaJY",
    "IsLatest": true,
    "LastModified": "2026-09-03T11:26:17+00:00"
  }
]
```
El delete marker (`IsLatest: true`) es más reciente que la versión con contenido (`IsLatest: false`) — confirma que es lo que está ocultando el archivo.

## Paso 2 — Borrar el delete marker

```bash
aws s3api delete-object \
  --bucket cmtr-iacp1ebx-s3-rfuv-bucket-822472 \
  --key accidentally_deleted_file.csv \
  --version-id 3VJUr3cRwlvWHhZRrc7VyF2pqrBOeaJY \
  --region eu-west-1
```
```json
{"DeleteMarker": true, "VersionId": "3VJUr3cRwlvWHhZRrc7VyF2pqrBOeaJY"}
```
La respuesta `"DeleteMarker": true` confirma que lo que se eliminó fue específicamente el delete marker (no una versión con contenido).

## Verificación

```bash
aws s3 ls s3://cmtr-iacp1ebx-s3-rfuv-bucket-822472/
```
```
2026-09-03 11:25:48         38 accidentally_deleted_file.csv
```
El archivo reaparece con su `LastModified` **original** (`11:25:48`, la fecha real de subida) — prueba de que se restauró la versión existente y no se subió nada nuevo.
