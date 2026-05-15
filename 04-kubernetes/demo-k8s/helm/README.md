# Helm chart for demo-k8s

This folder contains the Helm chart for the `demo-k8s` application.

## Install the Helm chart

From `04-kubernetes/demo-k8s/helm`:

```bash
helm install demo-k8s . --namespace demo-k8s --create-namespace
```

If the namespace already exists, use:

```bash
helm install demo-k8s . --namespace demo-k8s
```

## Upgrade the Helm release

After changing chart templates or values, run:

```bash
helm upgrade demo-k8s . --namespace demo-k8s
```

To apply only a values override file:

```bash
helm upgrade demo-k8s . --namespace demo-k8s -f values.yaml
```

## Uninstall the Helm release

```bash
helm uninstall demo-k8s --namespace demo-k8s
```

If you want to delete the namespace too:

```bash
kubectl delete namespace demo-k8s
```

## Modify the demo application

1. Edit chart files in this folder:
   - `values.yaml` for configuration values
   - `templates/*.yaml` for Kubernetes resources
   - `Chart.yaml` for chart metadata
2. Validate the chart:

```bash
helm lint .
```

3. Render the templates locally to review the generated manifests:

```bash
helm template demo-k8s .
```

4. Upgrade the release:

```bash
helm upgrade demo-k8s . --namespace demo-k8s
```

## Integrate with Argo CD

The Argo CD application should point to this folder path:

- `repoURL`: `https://github.com/cesarbuitragorey/devops-sandbox.git`
- `targetRevision`: `main`
- `path`: `04-kubernetes/demo-k8s/helm`
- `destination.namespace`: `demo-k8s`

If you already applied `argocd/demo-view.yaml`, you can sync the Argo CD app manually:

```bash
argocd app sync demo-view
```

To update the Argo CD app definition, edit `04-kubernetes/demo-k8s/argocd/demo-view.yaml` and reapply:

```bash
kubectl apply -f /home/zexar/devops-sandbox/repo/devops-sandbox/04-kubernetes/demo-k8s/argocd/demo-view.yaml
```

## Notes

- The current active deployment mechanism is Helm.
- The `legacy-app/` folder and `kustomization-old.yaml` are kept only as a backup of the previous Kustomize-based infra.
- Do not keep `templates/namespace.yaml` in this chart if the namespace is managed outside Helm, otherwise install may fail when the namespace already exists.
