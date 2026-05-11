# Ver namespace
kubectl get ns

# Ver StatefulSet
kubectl get sts -n demo-k8s

# Ver Pods con nombre estable
kubectl get pods -n demo-k8s

# Ver PVCs creados automáticamente
kubectl get pvc -n demo-k8s

# Describir el StatefulSet completo
kubectl describe statefulset web -n demo-k8s

# Describir un Pod específico
kubectl describe
kubectl describe pod web-0 -n demo-k8s
# Ver eventos del cluster
kubectl get events -n demo-k8s --sort-by=.metadata.creationTimestamp
# Ver logs de un Pod
kubectl logs web-0 -n demo-k8s
# Confirmar limpieza
kubectl get all -n demo-k8s
# Eliminar PVCs explícitamente (solo en laboratorio)
kubectl delete pvc --all -n demo-k8s
# Eliminar SOLO el StatefulSet
kubectl delete statefulset web -n demo-k8s
# Ver que los PVC siguen existiendo
kubectl get pvc -n demo-k8s
# Reducir a 2 réplicas
kubectl scale statefulset web -n demo
kubectl describe pod web-0 -n demo-k8s
kubectl delete all --all -n demo-k8s
kubectl get all -n demo-k8s
kubectl get pods,sts,pvc,svc -n demo-k8s
kubectl get pods -n demo-k8s
kubectl get statefulset -n demo-k8s
kubectl get deployments -n demo-k8s
kubectl get replicaset -n demo-k8s
kubectl get services -n demo-k8s
kubectl get pvc -n demo-k8s
kubectl get pv
kubectl get configmap -n demo-k8s
kubectl get secret -n demo-k8s
kubectl get ingress -n demo-k8s
kubectl get networkpolicy -n demo-k8s
kubectl api-resources --verbs=list --namespaced -o name \
| xargs -n 1 kubectl get -n demo-k8s