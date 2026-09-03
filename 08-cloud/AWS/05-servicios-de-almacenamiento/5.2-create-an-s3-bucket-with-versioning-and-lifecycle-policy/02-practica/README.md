# Práctica — Create an S3 Bucket with Versioning and Lifecycle Policy

## Enunciado de la tarea

> Create an S3 bucket with versioning enabled and configure a lifecycle policy to manage object versions efficiently.

**Región:** `eu-west-1`

**Recursos de la tarea:**
- Bucket `cmtr-iacp1ebx-bucket-1788359238`
- Lifecycle Policy `cmtr-iacp1ebx-rule`

**Objetivos (3 movimientos):**
1. Crear el bucket con versionado habilitado.
2. Subir un par de archivos `.txt` de prueba.
3. Configurar la regla de lifecycle: noncurrent versions → Standard-IA a los 30 días, eliminación permanente a los 50 días.

**Entorno real usado:** sandbox AWS, trabajado por **CLI** en CloudShell.

---

## Movimiento 1 — Crear el bucket y habilitar versionado

```bash
aws s3api create-bucket \
  --bucket cmtr-iacp1ebx-bucket-1788359238 \
  --region eu-west-1 \
  --create-bucket-configuration LocationConstraint=eu-west-1

aws s3api put-bucket-versioning \
  --bucket cmtr-iacp1ebx-bucket-1788359238 \
  --versioning-configuration Status=Enabled
```

## Movimiento 2 — Subir archivos de prueba

```bash
echo "archivo de prueba 1" > file1.txt
echo "archivo de prueba 2" > file2.txt

aws s3 cp file1.txt s3://cmtr-iacp1ebx-bucket-1788359238/
aws s3 cp file2.txt s3://cmtr-iacp1ebx-bucket-1788359238/
```

## Movimiento 3 — Lifecycle policy

```bash
cat > lifecycle-policy.json << 'EOF'
{
  "Rules": [
    {
      "ID": "cmtr-iacp1ebx-rule",
      "Status": "Enabled",
      "Filter": {},
      "NoncurrentVersionTransitions": [
        {
          "NoncurrentDays": 30,
          "StorageClass": "STANDARD_IA"
        }
      ],
      "NoncurrentVersionExpiration": {
        "NoncurrentDays": 50
      }
    }
  ]
}
EOF

aws s3api put-bucket-lifecycle-configuration \
  --bucket cmtr-iacp1ebx-bucket-1788359238 \
  --lifecycle-configuration file://lifecycle-policy.json
```

`Filter: {}` (filtro vacío) hace que la regla aplique a **todos** los objetos del bucket, sin restringir por prefijo ni tags.

## Verificación

```bash
aws s3api get-bucket-versioning --bucket cmtr-iacp1ebx-bucket-1788359238
aws s3api get-bucket-lifecycle-configuration --bucket cmtr-iacp1ebx-bucket-1788359238
aws s3 ls s3://cmtr-iacp1ebx-bucket-1788359238/
```
```json
{"Status": "Enabled"}
```
```json
{
    "Rules": [
        {
            "ID": "cmtr-iacp1ebx-rule",
            "Filter": {},
            "Status": "Enabled",
            "NoncurrentVersionTransitions": [{"NoncurrentDays": 30, "StorageClass": "STANDARD_IA"}],
            "NoncurrentVersionExpiration": {"NoncurrentDays": 50}
        }
    ]
}
```
```
2026-09-02 15:22:48         20 file1.txt
2026-09-02 15:22:51         20 file2.txt
```

Lab directo, sin incidentes.
