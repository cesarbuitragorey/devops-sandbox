# Task 11: Delete static pod `nginx-static`

This task deletes the static pod object for `nginx-static` from the `static` namespace.

## Script
- `task-11/delete-nginx-static.sh`

## How it works
- Uses `kubectl delete pod` with label selector `app=nginx-static`
- Targets namespace `static`
- Ignores missing pod errors

## Notes
If the static pod manifest still exists under the kubelet static manifest directory, the pod will be recreated automatically after deletion.

To verify:

```bash
./task-11/delete-nginx-static.sh
kubectl get pods -n static
```
