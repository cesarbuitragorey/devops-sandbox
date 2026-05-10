
🟡 1. Inspección Básica de Deployments
kubectl get deployments
# Lista todos los Deployments del namespace actual o que esta default
kubectl get deployments -n namespace
# Lista todos los Deployments del namespace actual
kubectl get deployment
# Forma equivalente (deployment y deployments son aceptados)
kubectl get deploy
# Forma abreviada (shortcut)
kubectl get deploy -n namespace_name
# Lista todos los Deployments en un los namespaces
kubectl get deployments -A
# Lista todos los Deployments en TODOS los namespaces
kubectl get deployments -o wide
# Muestra columnas adicionales: imágenes, estrategia, etc.
kubectl get deployments -n demo-k8s -o wide
# Muestra columnas adicionales: imágenes, estrategia, etc.
kubectl get all -n demo-k8s
# Muestra columnas adicionales: pods, hpa, replicaset, imágenes, estrategia, etc.
kubectl get deployment nginx-deployment
kubectl get deployment nginx-deployment -n demo-k8s
kubectl get deployment nginx-deployment -n demo-k8s -o wide
# Muestra estado resumido de un Deployment específico
kubectl <verbo> <recurso> <nombre> [flags]
kubectl describe deployment nginx-deployment
kubectl describe deployment nginx-deployment -n demo-k8s
``
# Muestra el detalle completo del Deployment:
# replicas deseadas, replicas actuales, eventos, errores
🟡 2. Relación Deployment → ReplicaSet → Pods
kubectl get rs
kubectl get rs -n demo-k8s
# Lista los ReplicaSets (normalmente creados por Deployments)
kubectl get rs --selector app=nginx
kubectl get rs --selector app=nginx-deploy -n demo-k8s
# Lista ReplicaSets usando labels del Deployment
kubectl describe rs <replicaset>
# Muestra qué Deployment creó el ReplicaSet y cuántos Pods maneja
kubectl get pods --selector app=nginx-deploy
# Lista Pods creados por un Deployment usando labels
kubectl describe pod <pod>
# Permite confirmar en "Controlled By" qué Deployment lo gobierna
🟠 3. Creación y Actualización de Deployments
kubectl apply -f deployment.yaml
# Crea o actualiza un Deployment de forma declarativa (RECOMENDADO)
kubectl apply -f .
# Aplica todos los YAML del directorio actual (deployments, hpa, etc.)
kubectl create deployment nginx \
--image=nginx:1.27
# Crea un Deployment de forma imperativa
# Útil para pruebas, NO recomendado para producción
kubectl create deployment nginx \
--image=nginx:1.27 \
--dry-run=client -o yaml
# Genera el YAML de un Deployment sin crearlo (plantilla)
🔵 4. Edición en Caliente de Deployments
kubectl edit deployment nginx-deployment
# Abre el Deployment en el editor por defecto
# Cambios se aplican inmediatamente
EDITOR=nano kubectl edit deployment nginx-deployment
# Fuerza un editor específico
kubectl get deployment nginx-deployment -o yaml
# Muestra el YAML completo del Deployment (solo lectura)
kubectl get deployment nginx-deployment -o json
# Muestra el Deployment en formato JSON
🔵 5. Escalado MANUAL de Deployments
kubectl scale deployment nginx-deployment --replicas=5
# Escala manualmente el número de Pods
kubectl scale deploy nginx-deployment --replicas=0
# Escala a cero Pods (apagado temporal controlado)
kubectl get deployment nginx-deployment
# Verifica replicas deseadas vs disponibles
kubectl get pods -w
# Observa en tiempo real cómo se crean o eliminan Pods
🟣 6. Rollouts (Actualizaciones Controladas)
kubectl rollout status deployment/nginx-deployment
# Muestra el progreso de un rollout en curso
kubectl rollout history deployment/nginx-deployment
# Muestra el historial de revisiones del Deployment
kubectl rollout history deployment/nginx-deployment --revision=2
# Muestra el detalle de una revisión específica
kubectl set image deployment/nginx-deployment \
nginx=nginx:1.28
# Actualiza la imagen del contenedor (dispara rollout)
kubectl rollout pause deployment/nginx-deployment
# Pausa un rollout en ejecución
kubectl rollout resume deployment/nginx-deployment
# Reanuda un rollout pausado
kubectl rollout undo deployment/nginx-deployment
# Revierte al deployment anterior automáticamente
kubectl rollout undo deployment/nginx-deployment --to-revision=1
# Revierte a una revisión específica
kubectl rollout history deployment/nginx-deployment
# Útil antes de un rollback para confirmar revisiones disponibles
🔴 7. Rollback (Reversión de Deployments)
kubectl rollout undo deployment/nginx-deployment
# Revierte al deployment anterior automáticamente
kubectl rollout undo deployment/nginx-deployment --to-revision=1
# Revierte a una revisión específica
kubectl rollout history deployment/nginx-deployment
# Útil antes de un rollback para confirmar revisiones disponibles
🟢 8. Restart Controlado de Deployments
kubectl rollout restart deployment/nginx-deployment
# Reinicia TODOS los Pods del Deployment sin cambiar imagen
# Muy usado para aplicar cambios de ConfigMaps/Secrets
kubectl get pods
# Verifica que los Pods sean recreados
🟢 9. Debugging de Deployments (Logs y Exec)
kubectl logs deployment/nginx-deployment
# Muestra logs del primer Pod del Deployment
kubectl logs deployment/nginx-deployment -c nginx
# Muestra logs de un contenedor específico
kubectl logs deployment/nginx-deployment --tail=50
# Muestra las últimas 50 líneas de logs
kubectl logs deployment/nginx-deployment -f
# Sigue los logs en tiempo real
kubectl exec -it deployment/nginx-deployment -- sh
# Abre una shell en uno de los Pods del Deployment
kubectl exec -it deployment/nginx-deployment -c nginx -- sh
# Abre shell en un contenedor específico
🔴 10. Troubleshooting Profundo de Deployments
kubectl describe deployment nginx-deployment
# Ver errores como:
# - ImagePullBackOff
# - CrashLoopBackOff
# - Falla de readiness/liveness
kubectl get events
# Lista eventos del namespace actual
kubectl get events --sort-by=.metadata.creationTimestamp
# Eventos ordenados cronológicamente (clave para debugging)
kubectl get pods
# Verifica estado real de Pods creados por el Deployment
kubectl describe pod <pod>
# Inspecciona por qué un Pod no levanta correctamente
