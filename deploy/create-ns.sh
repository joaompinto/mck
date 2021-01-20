#/bin/sh
set -eu

kubectl apply -f - << _EOF_
---
# Create the NS
apiVersion: v1
kind: Namespace
metadata:
    name: $1
    labels:
        name: $1
---
# Create the NS Admin Service Account
apiVersion: v1
kind: ServiceAccount
metadata:
    name: $1-admin
    namespace: $1
---
kind: Role
apiVersion: rbac.authorization.k8s.io/v1
metadata:
    name: $1-admin-role
    namespace: $1
rules:
    -   apiGroups: [""]
        resources: ["pods"]
        verbs: ["create", "get", "list", "watch", "update", "patch"]
---
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
    name: $1-admin-role-binding
    namespace: $1
subjects:
    -   kind: ServiceAccount
        name: $1-admin
        namespace: $1
roleRef:
    kind: Role
    name: $1-admin-role
    apiGroup: rbac.authorization.k8s.io
---
kind: NetworkPolicy
apiVersion: networking.k8s.io/v1
metadata:
    namespace: $1
    name: deny-from-other-namespaces
spec:
    podSelector:
        matchLabels:
    ingress:
    - from:
        - podSelector: {}
---
_EOF_
