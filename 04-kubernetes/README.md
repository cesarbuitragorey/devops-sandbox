# 🚀 Guía de Comandos de Kubernetes (kubectl)
## 🔍 Inspección de Recursos


04-kubernetes/
├── labs/                     # 👈 solo aprendizaje
│   ├── pods/
│   ├── replicasets/
│   ├── deployments/
│   ├── daemonsets/
│   └── ingress/
│
├── demo-app/                 # 👈 INTENCIÓN CLARA (GitOps)
│   ├── namespace.yaml
│   ├── deployment.yaml
│   ├── service.yaml
│   ├── ingress.yaml
│
└── argocd/
    └── demo-view.yaml
# Listar pods en el namespace actual
kubectl get pods
# Listar con detalles extendidos (IPs y nodos de destino)
kubectl get pods -o wide
# Ver el estado de los pods en TODOS los namespaces del clúster
kubectl get pods -A
# Ver los eventos y configuración detallada de un pod (útil para debuguear errores de inicio)
kubectl describe pod <nombre-del-pod>
```
## 🛠️ Creación y Gestión
```bash
# Crear y lanzar un pod simple de Nginx directamente desde la CLI
kubectl run mi-nginx --image=nginx
# Aplicar o actualizar la configuración de un pod definida en un archivo YAML
kubectl apply -f mi-pod.yaml
# Generar el código YAML de un pod sin crearlo (ideal para crear plantillas rápidamente)
kubectl run mi-pod --image=nginx --dry-run=client -o yaml > pod-template.yaml
# Eliminar un pod (esto enviará una señal de terminación elegante)
kubectl delete pod <nombre-del-pod>
```
## 📋 Logs y Monitoreo
```bash
# Ver la salida estándar (logs) de un pod
kubectl logs <nombre-del-pod>
# Seguir los logs en tiempo real (equivalente a 'tail -f')
kubectl logs -f <nombre-del-pod>
# Ver logs de un contenedor específico si el pod tiene más de uno
kubectl logs <nombre-del-pod> -c <nombre-del-contenedor>
# Ver logs de un pod que se colgó o reinició (instancia anterior)
kubectl logs <nombre-del-pod> --previous
```
## 💻 Interacción Directa
```bash
# Abrir una terminal interactiva dentro del contenedor (Bash)
# -i: interactivo, -t: tty (terminal)
kubectl exec -it <nombre-del-pod> -- /bin/bash
# Ejecutar un comando simple dentro del contenedor sin entrar en él
kubectl exec <nombre-del-pod> -- ls /app/data
# Crear un túnel para acceder a un puerto del pod desde tu localhost
# Ejemplo: accede a la web del pod en http://localhost:8080
kubectl port-forward <nombre-del-pod> 8080:80
# Copiar archivos desde tu PC hacia el interior del pod
kubectl cp ./config.json <nombre-del-pod>:/etc/config/config.json
```

## 🌌 Gestión de Namespaces
Los Namespaces son particiones virtuales dentro del clúster que ayudan a organizar y aislar recursos.
```bash
# Listar todos los namespaces existentes en el clúster
kubectl get namespaces
# Crear un nuevo namespace para organizar tus recursos
kubectl create namespace <nombre-namespace>
# Ver todos los recursos (pods, services, etc.) de un namespace específico
kubectl get all -n <nombre-namespace>
# Ejecutar un comando (como listar pods) en TODOS los namespaces a la vez
kubectl get pods --all-namespaces
# Describir un namespace para ver cuotas de recursos o límites
kubectl describe namespace <nombre-namespace>
# Eliminar un namespace (CUIDADO: Borra todos los recursos que contiene)
kubectl delete namespace <nombre-namespace>
```
## ⚙️ Configuración del Contexto (Namespace por defecto)
Si no quieres escribir `-n <nombre>` en cada comando, puedes cambiar el contexto:
```bash
# Ver en qué namespace y contexto estás trabajando actualmente
kubectl config view --minify | grep namespace:
# Cambiar permanentemente el namespace por defecto para tu sesión actual
# Evita tener que usar el flag -n en cada comando subsiguiente
kubectl config set-context --current --namespace=<nombre-namespace>
# Verificar si el cambio se aplicó correctamente
kubectl config get-contexts
```
## 📦 Despliegue de Pods en un Namespace
```bash
# Crear un pod indicando específicamente en qué namespace debe vivir
kubectl run mi-pod --image=nginx -n <nombre-namespace>

# Aplicar un archivo YAML forzando un namespace (ignora el definido en el YAML)
kubectl apply -f pod.yaml --namespace=<nombre-namespace>
```
### 🟢 Nivel Básico: Exploración y Gestión Simple
```bash
kubectl version                              # Muestra la versión del cliente y del servidor del clúster
kubectl cluster-info                         # Verifica que el clúster esté activo y responde
kubectl get pods -A                             # Lista los Pods en el namespace actual
kubectl get pods -n <nombre-namespace>       # Lista los Pods en un namespace específico
kubectl describe pod <nombre-pod>            # Muestra detalles internos (eventos, errores, IP) de un Pod
kubectl logs <nombre-pod>                    # Imprime los logs (salida de consola) del contenedor
kubectl apply -f archivo.yaml                # Crea o actualiza recursos definidos en un archivo YAML
kubectl delete -f archivo.yaml               # Elimina todos los recursos definidos en el archivo
```

### 🟡 Nivel Intermedio: Administración de Recursos
```bash
kubectl get all                              # Lista TODO: pods, servicios, deployments y replicasets
kubectl get namespaces                       # Lista los espacios de trabajo (namespaces) actuales
kubectl create namespace <nombre>            # Crea un nuevo espacio de trabajo lógico
kubectl port-forward <pod> 8080:80           # Túnel temporal: accede a un puerto del Pod desde tu localhost
kubectl exec -it <pod> -- sh                 # Abre una terminal dentro de un contenedor en ejecución
kubectl get nodes                            # Lista los nodos (máquinas físicas o virtuales) del clúster
kubectl run nginx-test --image=nginx         # Crea un Pod rápidamente sin usar archivos YAML
```

### 🟠 Nivel Avanzado: Control de Despliegues (Deployments)
```bash
kubectl get deployments                      # Lista los despliegues y su estado de salud
kubectl scale deployment <nombre> --replicas=5 # Cambia el número de copias (pods) en tiempo real
kubectl rollout history deployment/<nombre>  # Mira el historial de versiones de tu aplicación
kubectl rollout undo deployment/<nombre>     # Vuelve a la versión anterior (Rollback) si algo falla
kubectl set image deployment/<nom> container=<img:v2> # Actualiza la versión de la imagen sin apagar la app
```

### 🔴 Nivel Pro: Troubleshooting y Mantenimiento
```bash
kubectl top pod                              # Muestra el consumo real de CPU y RAM de los Pods (requiere metrics-server)
kubectl top node                             # Muestra el consumo de recursos de las máquinas del clúster
kubectl get events --sort-by='.lastTimestamp' # Lista los últimos eventos del clúster (ideal para debug)
kubectl auth can-i create pods               # Verifica si tu usuario tiene permisos para crear pods (RBAC)
kubectl api-resources                        # Lista todos los tipos de recursos que soporta tu clúster
kubectl explain pods                         # Documentación interactiva sobre los campos de un YAML de Pod
kubectl config get-contexts                  # Lista todos los clústeres configurados en tu máquina
kubectl config use-context <nombre>          # Cambia de un clúster a otro (ej. de Minikube a Producción)
```

### 🛠️ Comandos Extra (Específicos para Minikube)
```bash
minikube start                               # Inicia el clúster local
minikube dashboard                           # Abre la interfaz gráfica en el navegador
minikube service <nombre-servicio>           # Te da la URL para acceder a una app desde fuera del clúster
```
kubectl apply -f replicaset.yml               # Crea o actualiza el ReplicaSet de forma declarativa
kubectl get rs                                # Lista los ReplicaSets en el namespace actual
kubectl get rs -o wide                        # Lista con detalles extra (imágenes, selectores)
kubectl describe rs <nombre-rs>               # Muestra el estado detallado y eventos de sistema
kubectl edit rs <nombre-rs>                   # Abre el YAML en el editor para cambios en caliente
kubectl describe hpa frontend-hpa 
kubectl delete rs <nombre-rs>                 # Elimina el RS y todos sus Pods asociados
kubectl delete rs <nombre-rs> --cascade=orphan # Elimina el RS pero mantiene los Pods vivos

Escalamiento y Disponibilidad
Bash
kubectl scale rs <nombre-rs> --replicas=5     # Escala manualmente a 5 réplicas
kubectl autoscale rs <nombre-rs> --min=2 --max=10 --cpu-percent=80 # comando antiguo Configura autoescalado
kubectl autoscale rs frontend --min=2 --max=10 --cpu=80%
kubectl get hpa