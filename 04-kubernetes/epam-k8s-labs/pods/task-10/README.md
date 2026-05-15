# Task 10: Static Pod `nginx-static`

This task defines a static pod manifest for a kubelet-managed nginx pod.

## Requirements
- Pod name: `nginx-static`
- Image: `nginx:alpine`
- Label: `app=nginx-static`
- Namespace: `static`
- Container port: `80`

## Manifest
- `task-10/namespace.yaml`
- `task-10/nginx-static.yaml`

## Verification
A static pod is recreated by the kubelet after deletion. If the manifest is installed on a node in the kubelet static pod directory, deleting the pod should result in it being recreated automatically.

## Notes
Static pods are created by the kubelet from files placed in the node's static pod manifest directory, not by `kubectl apply` against the API server.

If you run `kubectl get pods -n static` and see `No resources found`, it means the pod has not yet been created by the kubelet from this manifest.

To install the static pod on k3s:

1. Create the namespace if needed:
   ```bash
   kubectl apply -f task-10/namespace.yaml
   ```
2. Copy `task-10/nginx-static.yaml` to the k3s agent static pod directory:
   ```bash
   sudo cp task-10/nginx-static.yaml /var/lib/rancher/k3s/agent/pod-manifests/
   ```
3. Wait a few seconds and verify:
   ```bash
   kubectl get pods -n static
   ```

4. To verify recreation, delete the actual pod name shown in the output and confirm it returns to Running:
   ```bash
   kubectl delete pod <actual-pod-name> -n static
   kubectl get pods -n static
   ```

Note: on k3s, the created static pod may appear with a node suffix, for example `nginx-static-<node-name>`.

## Secret phrase
The manifest includes the copied secret phrase `supersecret` as a task marker.
