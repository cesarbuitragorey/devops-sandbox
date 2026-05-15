# Kubernetes Pods Lab - Task Organization

This folder organizes the pod lab exercises into separate task directories and documents the exercise statement, workflow, and result for each step.

## Task folders
- `task-1/` - `nginx-pod.yaml`
- `task-2/` - `save-me-pod.yaml`
- `task-3/` - `web-fixed.yaml`, `web-pod-backup.yaml`
- `task-4/` - `redis-fixed.yaml`, `redis-pod-backup.yaml`
- `task-5/` - `redis-bad.yaml`
- `task-6/` - `redis.yaml`
- `task-7/` - `envtest-pod.yaml`
- `task-8/` - `i-know-who-i-am.yaml`
- `task-9/` - `delete-pods-job.yaml`
- `task-10/` - `namespace.yaml`, `nginx-static.yaml`
- `task-11/` - `delete-nginx-static.sh`

## Exercise summary

### Task 1: Crear un pod básico de NGINX
- Enunciado: Crear un pod `nginx-pod` que ejecute la imagen `nginx:alpine`.
- Workflow: El pod se define en `task-1/nginx-pod.yaml` con un solo contenedor y el puerto 80 expuesto.
- Resultado: Manifest listo para aplicar en Kubernetes.

### Task 2: Guardar el manifiesto de un pod existente
- Enunciado: Extraer y guardar el manifiesto YAML del pod `save-me` en `~/.k8s_pods/save-me-pod.yml`.
- Workflow: Se creó `task-2/save-me-pod.yaml` exportando el pod existente desde el clúster.
- Resultado: El manifiesto del pod `save-me` está preservado en el repositorio para referencia.

### Task 3: Corregir un pod `web` roto
- Enunciado: Reparar el pod `web` en el namespace `trouble` cambiando la imagen a `nginx:1.19-alpine`.
- Workflow: Se guardó el manifiesto corregido en `task-3/web-fixed.yaml` y se conservó el backup original en `task-3/web-pod-backup.yaml`.
- Resultado: El pod `web` ahora usa una imagen válida de NGINX.

### Task 4: Corregir un pod `redis-db` con comando inválido
- Enunciado: Ajustar el pod `redis-db` para usar `busybox` con `sleep infinity` en lugar de un error de sintaxis.
- Workflow: Se creó `task-4/redis-fixed.yaml` con el comando corregido y se preservó el backup en `task-4/redis-pod-backup.yaml`.
- Resultado: El pod `redis-db` puede ejecutarse sin fallo de comando.

### Task 5: Crear un pod `redis` con imagen intencionalmente errónea
- Enunciado: Definir un pod `redis` con la imagen incorrecta `redis:123` para simular un error.
- Workflow: Se guardó el manifiesto en `task-5/redis-bad.yaml`.
- Resultado: El manifest muestra el escenario del pod con imagen no existente.

### Task 6: Corregir el pod `redis` a una imagen válida
- Enunciado: Actualizar el pod `redis` para usar `redis:5-alpine`.
- Workflow: Se creó `task-6/redis.yaml` con la imagen válida.
- Resultado: El pod `redis` está definido correctamente.

### Task 7: Crear el pod `envtest` y guardar los logs
- Enunciado: Definir un pod `envtest` que ejecute un script para imprimir variables de entorno.
- Workflow: El manifiesto está en `task-7/envtest-pod.yaml` y los logs se guardaron en `/home/zexar/k8s_pods/default-envtest.log`.
- Resultado: El pod está preservado en su propio task folder.

### Task 8: Crear un pod con variables de entorno automáticas
- Enunciado: Crear un pod `i-know-who-i-am` en el namespace `default` usando `busybox:1.34` y el comando `env && sleep infinity`.
- Workflow: Se creó `task-8/i-know-who-i-am.yaml` con variables de entorno inyectadas desde la Downward API:
  - `MY_NODE_NAME` = `spec.nodeName`
  - `MY_POD_NAME` = `metadata.name`
  - `MY_POD_NAMESPACE` = `metadata.namespace`
  - `MY_POD_IP` = `status.podIP`
  - `MY_POD_SERVICE_ACCOUNT` = `spec.serviceAccountName`
- Resultado: El pod está definido para obtener automáticamente sus metadatos de Kubernetes en tiempo de ejecución.

### Task 9: Eliminar todos los pods en el namespace `clean-up`
- Enunciado: Borrar todos los pods existentes en el namespace `clean-up`.
- Workflow: Se creó `task-9/delete-pods-job.yaml`, un Job de Kubernetes que ejecuta `kubectl delete pods --all --namespace clean-up` usando un ServiceAccount con RBAC específico.
- Resultado: El manifiesto permite ejecutar la limpieza desde Kubernetes, sin depender de un script shell local.

### Task 10: Crear un static pod `nginx-static`
- Enunciado: Crear un static pod `nginx-static` en el namespace `static` usando la imagen `nginx:alpine`, etiqueta `app=nginx-static` y puerto `80`.
- Workflow: Se creó `task-10/nginx-static.yaml` como un manifiesto de static pod con comentario de control para el secret phrase.
- Resultado: El manifiesto está listo para ser colocado en el directorio de static pods del kubelet; el pod debe recrearse tras borrarlo.

## Nota de organización
Cada tarea está aislada en su propio directorio para evitar que los recursos de una tarea interfieran con las demás. Los backups de manifiestos corregidos se mantienen junto a la tarea correspondiente para facilitar la revisión.
