# 1️⃣ Prometheus + Grafana (Helm, recomendado)
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm install monitoring prometheus-community/kube-prometheus-stack \
  --namespace monitoring --create-namespace
node-exporter:

corre como DaemonSet
monta rutas del host: /proc, /sys, /rootfs
necesita mountPropagation compartido

Estos entornos NO lo soportan plenamente:

Docker Desktop
WSL2
Rancher Desktop
Minikube con driver Docker
Algunos k3s locales

📌 En producción (bare‑metal, cloud, EKS/GKE/AKS) sí funciona.
kubectl -n monitoring port-forward svc/monitoring-grafana 3000:80

Prometheus  → métricas
Grafana     → dashboards + logs
Loki        → backend de logs
Promtail    → agente que lee logs de pods

