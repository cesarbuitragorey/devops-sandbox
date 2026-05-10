
## 1️⃣ Listar DaemonSets

```bash
# Lista DaemonSets del namespace actual
kubectl get daemonset
# Lista DaemonSets del namespace kube-system
kubectl get daemonset -n kube-system
# Atajo común
kubectl get ds -n kube-system
# Describir el DaemonSet completo
kubectl describe daemonset fluentd-elasticsearch -n kube-system
# Listar Pods usando el label selector
kubectl get pods -n kube-system -l app=fluentd-elasticsearch
# Ver también el nodo donde corre cada Pod
kubectl get pods -n kube-system -o wide | grep fluentd
# Ver Pods que corren en un nodo específico
kubectl get pods -A --field-selector spec.nodeName=<NOMBRE_DEL_NODO>
# Ver los detalles de un Pod específico
kubectl describe pod <NOMBRE_DEL_POD> -n kube-system
``
# Ver logs del Pod
kubectl logs <NOMBRE_DEL_POD> -n kube-system
# Seguir logs en tiempo real
kubectl logs -f <NOMBRE_DEL_POD> -n kube-system
# Si hay más de un contenedor
kubectl logs <NOMBRE_DEL_POD> -n kube-system -c <NOMBRE_CONTENEDOR>
# Eliminar un Pod del DaemonSet
kubectl delete pod <NOMBRE_DEL_POD> -n kube-system
# Añadir un nodo al cluster
minikube node add
# Ver nuevos Pods del DaemonSet
kubectl get pods -n kube-system | grep fluentd
# Editar el manifiesto del DaemonSet
kubectl edit daemonset fluentd-elasticsearch -n kube-system
# Forzar recreación secuencial de Pods
kubectl rollout restart daemonset fluentd-elasticsearch -n kube-system
# Elimina el DaemonSet y TODOS sus Pods
kubectl delete daemonset fluentd-elasticsearch -n kube-system
