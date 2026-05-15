demo-k8s/
├── helm/
│   ├── Chart.yaml
│   ├── values.yaml
│   ├── templates/
│   │   ├── namespace.yaml
│   │   ├── serviceaccount.yaml
│   │   ├── app-role.yaml
│   │   ├── app-rolebinding.yaml
│   │   ├── cicd-serviceaccount.yaml
│   │   ├── cicd-role.yaml
│   │   ├── cicd-rolebinding.yaml
│   │   ├── configmap.yaml
│   │   ├── secret.yaml
│   │   ├── deployment.yaml
│   │   ├── service.yaml
│   │   ├── hpa.yaml
│   │   ├── pv.yaml
│   │   ├── pvc.yaml
│   │   ├── pvc-pod.yaml
│   │   ├── emptydir-pod.yaml
│   │   ├── hostpath-pod.yaml
│   │   ├── job.yaml
│   │   └── cronjob.yaml
├── legacy-app/
│   ├── namespace.yaml
│   ├── base-app/
│   ├── config/
│   ├── jobs/
│   ├── rbac/
│   └── storage/
├── kustomization-old.yaml
└── argocd/
    └── demo-view.yaml

Nota:
- La implementación actual usa Helm desde `helm/`.
- `legacy-app/` y `kustomization-old.yaml` se mantienen como respaldo de la infraestructura tradicional con Kustomize.
- Si prefieres trabajar solo con Helm, puedes ignorar esos respaldos.
