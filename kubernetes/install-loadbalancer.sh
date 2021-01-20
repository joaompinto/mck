#/bin/sh
export LIBVIRT_DEFAULT_URI=qemu:///system

kubepg_net=$(virsh net-dumpxml kubepg | grep -oP "ip address='\K\d+\.\d+.\d+")

kubectl apply -f https://raw.githubusercontent.com/google/metallb/v0.8.1/manifests/metallb.yaml
kubectl apply -f - << _EOF_
---
apiVersion: v1
kind: ConfigMap
metadata:
    namespace: metallb-system
    name: config
data:
    config: |
        address-pools:
        -   name: default
            protocol: layer2
            addresses:
                - ${kubepg_net}.200-${kubepg_net}.250
_EOF_
