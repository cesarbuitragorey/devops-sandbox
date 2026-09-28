# Teoría — Task 1.3: AWS IaC with Terraform: Create an Object Storage

## Por qué no basta con "S3 es privado por defecto"

Un `aws_s3_bucket` recién creado no tiene ninguna política ni ACL pública, así que en la práctica ya nace privado. Pero "privado porque no se configuró nada público" no es lo mismo que "privado de forma explícita y verificable" — depender solo del comportamiento por defecto deja la puerta abierta a que alguien agregue después una bucket policy o ACL pública sin que nada lo bloquee. El recurso `aws_s3_bucket_public_access_block`, con sus 4 flags en `true` (`block_public_acls`, `block_public_policy`, `ignore_public_acls`, `restrict_public_buckets`), convierte esa privacidad implícita en una restricción activa a nivel de bucket: incluso si alguien intenta adjuntar una policy o ACL pública más adelante, S3 la rechaza o la ignora. Es la diferencia entre "no configuré nada público" y "configuré explícitamente que nada público sea posible".

## Separación de responsabilidades entre `aws_s3_bucket` y sus sub-recursos

Desde la v4 del provider de AWS, `aws_s3_bucket` dejó de aceptar directamente atributos como `acl`, `versioning`, `server_side_encryption_configuration` o `public_access_block` embebidos en el propio bloque — cada uno de esos aspectos ahora es un recurso separado (`aws_s3_bucket_public_access_block`, `aws_s3_bucket_versioning`, `aws_s3_bucket_server_side_encryption_configuration`, etc.) que referencia al bucket por `bucket = aws_s3_bucket.this.id`. Esto es más verboso que la v3, pero hace que cada aspecto de configuración del bucket sea independiente y explícito en el plan — se ve claramente en el diff qué cambia exactamente en cada `apply`.

## La task más simple del módulo no significa menos rigor en las reglas comunes

A diferencia de las tasks anteriores (VPC, EC2+SSH), esta solo pedía un archivo (`storage.tf`) y un recurso central. Aun así, las reglas comunes (`versions.tf`, variables sin `default`, valores en `terraform.tfvars`, outputs con descripción) se mantienen idénticas — el tamaño de la infraestructura no cambia el estándar de higiene del código, y el checker de la plataforma las valida exactamente igual que en tasks más grandes.
