# 🚀 Guía de Comandos de Kubernetes (kubectl)

### 🟢 Nivel Básico: Exploración y Gestión Simple
```bash
kubectl version                              # Muestra la versión del cliente y del servidor del clúster
kubectl cluster-info                         # Verifica que el clúster esté activo y responde
kubectl get pods                             # Lista los Pods en el namespace actual
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
---
