#!/bin/sh
set -eu

NS=$1
KUBECFG_FILE_NAME=$HOME/.kubepg/${NS}-admin.conf

ca_file=$(mktemp)
chmod 0700 $ca_file
SECRET_NAME=$(kubectl get sa ${NS}-admin --namespace ${NS} -o json | jq -r .secrets[].name)
kubectl get secret --namespace ${NS} "${SECRET_NAME}" -o json | jq -r '.data["ca.crt"]' | base64 --decode > "$ca_file"
USER_TOKEN=$(kubectl get secret --namespace ${NS} "${SECRET_NAME}" -o json | jq -r '.data["token"]' | base64 --decode)
context=$(kubectl config current-context)
CLUSTER_NAME=$(kubectl config get-contexts "$context" | awk '{print $3}' | tail -n 1)
ENDPOINT=$(kubectl config view -o jsonpath="{.clusters[?(@.name == \"${CLUSTER_NAME}\")].cluster.server}")
kubectl config set-cluster "${CLUSTER_NAME}" --kubeconfig="${KUBECFG_FILE_NAME}" --server="${ENDPOINT}" --certificate-authority=$ca_file --embed-certs=true
kubectl config set-credentials "${NS}-admin-${CLUSTER_NAME}" --kubeconfig=${KUBECFG_FILE_NAME} --token="${USER_TOKEN}"
kubectl config set-context "${NS}-admin-${CLUSTER_NAME}" --kubeconfig="${KUBECFG_FILE_NAME}" --cluster="${CLUSTER_NAME}" --user="${NS}-admin-${CLUSTER_NAME}" --namespace ${NS}
kubectl config use-context "${NS}-admin-${CLUSTER_NAME}" --kubeconfig="${KUBECFG_FILE_NAME}"
echo
echo Config was saved at ${KUBECFG_FILE_NAME}
echo 
echo You can switch to these credentials using:
echo
echo "  export KUBECONFIG=${KUBECFG_FILE_NAME}"
echo
exit 0