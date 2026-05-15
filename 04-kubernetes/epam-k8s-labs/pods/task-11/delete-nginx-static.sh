#!/bin/sh

set -e

NAMESPACE="static"
LABEL="app=nginx-static"

echo "Deleting static pod(s) with label ${LABEL} in namespace ${NAMESPACE}..."
kubectl delete pod --namespace "${NAMESPACE}" --selector "${LABEL}" --ignore-not-found

echo "Pod deletion requested. If the static manifest still exists, kubelet will recreate the pod."