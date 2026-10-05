# Teoría — Task 1.11: AWS IaC with Terraform: Move State to Other Backends

## Cambiar de backend es cambiar *dónde vive* el state, no la infraestructura

El lab anterior movió un recurso entre dos states; este mueve el state completo de un lugar a otro (de un bucket S3 a otro). En ambos casos AWS no recibe ninguna llamada de escritura: Terraform solo copia el archivo de state y, a partir de ahí, lo lee y lo escribe en el nuevo lugar. La política IAM de AWS nunca se toca, por eso el `plan` posterior da *No changes* y el ID del recurso es idéntico (lo que comprueba la plataforma).

## `terraform init -migrate-state`: detecta el cambio y copia

El flujo es: (1) inicializar con el backend viejo, (2) editar el bloque `backend` del código para apuntar al nuevo, (3) volver a ejecutar `terraform init -migrate-state`. Terraform compara la configuración guardada en `.terraform/` con la del código, ve que el backend cambió ("Backend configuration changed!") y ofrece copiar el state existente al destino. Sin `-migrate-state`, `init` en ese punto fallaría pidiendo elegir entre `-migrate-state` y `-reconfigure`. Este último (`-reconfigure`) hace lo contrario: abandona el state del backend viejo y empieza el nuevo vacío — con una política IAM ya existente, eso habría hecho que el siguiente `plan` propusiera crear de nuevo algo que ya existe.

## `-force-copy` evita la confirmación interactiva

Por defecto, la migración pregunta "Do you want to copy existing state to the new backend?" y espera `yes`. `-force-copy` lo responde afirmativamente por uno, útil cuando el comando corre en un script o en una terminal donde un prompt puede perderse (cosa que ya pasó en otros labs con `terraform apply`).

## El `lineage` cambia al migrar, y está bien

Al comparar el state original con el migrado, la única diferencia fue el campo `lineage`. El `lineage` es un identificador único del *historial* de un state (junto con `serial`, que cuenta sus versiones): Terraform lo usa para evitar mezclar por accidente states de historiales distintos. Al migrar hacia un backend destino nuevo, Terraform le asigna el suyo. Lo que importa para considerar la migración correcta es que los recursos y sus atributos (incluido el ARN) sean idénticos, y que `plan` no proponga cambios; la plataforma lo comprobó comparando el ID de la política, no el archivo byte a byte.

## Backup antes de migrar, siempre

Antes de tocar el backend se hizo `terraform state pull > backup_original.tfstate`. Una migración que sale mal (permisos del bucket destino, región equivocada) puede dejar el state en un estado incierto; con el backup en mano siempre se puede recuperar con `terraform state push`. Como en el lab 1.10, estos `*.tfstate` locales no se versionan (pueden contener datos sensibles), y el `.gitignore` los excluye.

## El código final apunta al backend nuevo

A diferencia del lab anterior, aquí el `providers.tf` que se commitea tiene el bucket **nuevo** escrito en el bloque `backend` — el enunciado pide mantener la configuración "consistente con el bucket destino", y la plataforma revisa esa configuración (check "Terraform uses the new S3 backend"). Es el estado final correcto: el repositorio describe dónde vive el state *ahora*.
