# Práctica — Configuring IAM Policies With Conditions

## Enunciado de la tarea

> Explore and configure IAM policies with conditions for a given IAM instance profile and test it on an EC2 instance.

**Región:** `eu-west-1`

**Recursos de la tarea** (ya provisionados por el sandbox):
- EC2 Instance: `cmtr-iacp1ebx-iam-c-instance` (`i-0947d717e33759f32`, IP público `3.250.77.53`)
- IAM Instance Profile: `cmtr-iacp1ebx-iam-c-instance_profile`
- IAM Role: `cmtr-iacp1ebx-iam-c-iam_role` (con permisos predefinidos que no debía modificar)
- S3 Bucket: `cmtr-iacp1ebx-iam-c-bucket-1878954`

**Objetivos (2 movimientos):** dos políticas inline nuevas en el rol:
1. `deny-s3-policy`: denegar todas las acciones Get/List en S3 cuando la request viene del IP público de la instancia.
2. `deny-ec2-policy`: denegar todas las acciones Describe en EC2 cuando la request es hacia la región `eu-west-1`.

**Entorno real usado:** sandbox AWS, cuenta `970378220557`. Trabajé por **CLI**, con verificación final dentro de la propia instancia vía **Session Manager**.

---

## 0. Obtener el IP público de la instancia

```bash
aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=cmtr-iacp1ebx-iam-c-instance" \
  --query 'Reservations[].Instances[].[InstanceId,PublicIpAddress,State.Name]' \
  --output table --region eu-west-1
```
```
i-0947d717e33759f32  |  3.250.77.53  |  running
```

## Movimiento 1 — `deny-s3-policy`

```bash
cat > deny-s3-policy.json << EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Deny",
      "Action": ["s3:Get*", "s3:List*"],
      "Resource": "*",
      "Condition": {
        "IpAddress": { "aws:SourceIp": "3.250.77.53/32" }
      }
    }
  ]
}
EOF

aws iam put-role-policy \
  --role-name cmtr-iacp1ebx-iam-c-iam_role \
  --policy-name deny-s3-policy \
  --policy-document file://deny-s3-policy.json \
  --region eu-west-1
```

### Incidente: `Resource` demasiado acotado — check de la plataforma falló en `s3:ListAllMyBuckets`

Mi primer intento limitó el `Resource` solo al ARN del bucket de la tarea:
```json
"Resource": [
  "arn:aws:s3:::cmtr-iacp1ebx-iam-c-bucket-1878954",
  "arn:aws:s3:::cmtr-iacp1ebx-iam-c-bucket-1878954/*"
]
```
Esto bloqueaba correctamente `s3:ListBucket`/`s3:GetObject` sobre ese bucket, pero el check automatizado #10 de la plataforma probó `s3:ListAllMyBuckets` (listar *todos* los buckets de la cuenta) y **no** lo bloqueó — porque esa acción siempre opera sobre `Resource: "*"`, nunca sobre un ARN de bucket específico, así que mi condición de recurso acotada nunca hacía match.

**Fix**: cambiar `Resource` a `"*"` (arriba ya reflejado) — el enunciado decía "deny all Get and List actions **on the S3 bucket service**", es decir a nivel de todo el servicio, no solo ese bucket puntual. `put-role-policy` sobre el mismo nombre de política simplemente sobreescribe la versión anterior, sin necesidad de borrar nada.

## Movimiento 2 — `deny-ec2-policy`

```bash
cat > deny-ec2-policy.json << EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Deny",
      "Action": "ec2:Describe*",
      "Resource": "*",
      "Condition": {
        "StringEquals": { "aws:RequestedRegion": "eu-west-1" }
      }
    }
  ]
}
EOF

aws iam put-role-policy \
  --role-name cmtr-iacp1ebx-iam-c-iam_role \
  --policy-name deny-ec2-policy \
  --policy-document file://deny-ec2-policy.json \
  --region eu-west-1
```

## Verificación — dentro de la instancia (Session Manager)

### Incidente: probar desde CloudShell/admin en vez de desde la instancia

Mi primer intento de "verificación" corrió `aws s3 ls` y `aws ec2 describe-instances` desde mi propia sesión de CloudShell (con credenciales de administrador del sandbox) — ambos comandos **funcionaron sin error**, lo cual parecía indicar que las políticas no servían. En realidad el problema era el método de prueba: esas políticas `Deny` están adjuntas únicamente al rol `cmtr-iacp1ebx-iam-c-iam_role`, no a mis credenciales de administrador, y la condición de IP tampoco podía cumplirse desde una IP que no es la de la instancia.

**Fix**: conectarse a la instancia real vía Session Manager, donde el CLI usa automáticamente las credenciales del instance profile:
```bash
aws ssm start-session --target i-0947d717e33759f32 --region eu-west-1
```
Y ya **dentro** de la instancia (prompt `sh-4.2$`, no `~ $` de CloudShell):
```bash
aws s3api list-buckets
aws s3 ls s3://cmtr-iacp1ebx-iam-c-bucket-1878954
aws ec2 describe-instances --region eu-west-1
```

Resultado correcto tras el fix del Movimiento 1:
```
An error occurred (AccessDenied) when calling the ListAllMyBuckets operation: ...
is not authorized to perform: s3:ListAllMyBuckets with an explicit deny in an identity-based policy

An error occurred (AccessDenied) when calling the ListObjectsV2 operation: ...
is not authorized to perform: s3:ListBucket on resource "arn:aws:s3:::cmtr-iacp1ebx-iam-c-bucket-1878954" with an explicit deny in an identity-based policy

An error occurred (UnauthorizedOperation) when calling the DescribeInstances operation: ...
is not authorized to perform: ec2:DescribeInstances with an explicit deny in an identity-based policy
```

**Lección general de este lab**: dos maneras distintas de invalidar una prueba de política sin que la política en sí esté mal — (1) probar con las credenciales equivocadas (admin en vez del rol real), y (2) acotar el `Resource` a un ARN específico cuando la acción que se quiere bloquear opera a nivel de todo el servicio.
