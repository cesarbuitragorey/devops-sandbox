# Teoría — Task 1.10: AWS IaC with Terraform: Move Resources between State Files

## El state es un mapa "recurso en código → recurso real", y se puede reasignar sin tocar la nube

Este lab es el primero donde el objetivo no es crear ni modificar infraestructura, sino cambiar *quién la gestiona*. El recurso `aws_iam_policy.custom_policy` ya existía en AWS y estaba registrado en el state `tf_code_1.tfstate`. `terraform state mv` reasigna esa entrada a otro state (`tf_code_2.tfstate`) sin hacer ninguna llamada de escritura a AWS: solo mueve el registro "este recurso del código corresponde a esta política real (por su ARN)". Por eso el ID del recurso no cambia (check 12 de la plataforma) y la política nunca se recrea.

## Código y state tienen que cambiar juntos

Mover solo el state deja la configuración desincronizada: si `tf_code_1` siguiera declarando el recurso, su siguiente `plan` vería "está en el código pero no en el state" y propondría **crearlo de nuevo**; y `tf_code_2`, al revés, vería un recurso en el state sin declaración en el código y propondría **destruirlo**. Por eso el flujo completo son tres cosas coordinadas: mover la entrada de state, quitar la definición del origen y agregarla (idéntica) al destino. El criterio de éxito es que `plan` dé *No changes* en ambos directorios.

## Con backends remotos, `state mv` necesita archivos locales de por medio

`terraform state mv -state-out=...` trabaja bien con archivos de state locales. Con dos backends S3 distintos, el patrón seguro es: bajar cada state (`terraform state pull`), mover entre las copias locales y subir el resultado (`terraform state push`). Esto además da backups gratis (los `pull` originales) por si algo sale mal.

## Orden de los `push`: primero el destino, después el origen

Si se empujara primero el origen (ya sin el recurso) y fallara el segundo push, el recurso quedaría sin dueño en ningún state — vivo en AWS pero invisible para Terraform. Empujando primero el destino, en el peor caso el recurso aparece en los dos states a la vez, lo cual es recuperable simplemente repitiendo el segundo paso. Es la misma lógica de "primero escribir lo nuevo, luego borrar lo viejo" de cualquier migración.

## Backend parcial: valores vacíos completados con `-backend-config`

Los `providers.tf` del repo traen `bucket = ""`, `key = ""`, `region = ""`. Terraform permite una *configuración parcial* del backend: lo que falta se pasa en `terraform init -backend-config="clave=valor"`. Así el mismo código puede apuntar a distintos buckets o keys según el entorno sin editar archivos, y no hay que commitear nombres de bucket en el repo. La plataforma hace lo mismo al verificar.

## Archivos de state fuera del repositorio

Los `*.tfstate` (backups y copias de trabajo) pueden contener datos sensibles y no deben versionarse; el `.gitignore` de la carpeta los excluye. Solo el código final (y el lock file de providers) va al repo.
