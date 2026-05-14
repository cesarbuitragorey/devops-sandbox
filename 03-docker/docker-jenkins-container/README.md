
demo-kubernetes/
├── app/
│   ├── namespace.yaml
│   ├── deployment.yaml
│   ├── service.yaml
│   ├── hpa.yaml
│   └── kustomization.yaml
└── argocd/
    └── demo-view.yaml


docker exec jenkins-server cat /var/jenkins_home/secrets/initialAdminPassword