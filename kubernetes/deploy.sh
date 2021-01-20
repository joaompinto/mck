#!/bin/sh
set -eu

export LIBVIRT_DEFAULT_URI=qemu:///system
kubepg_net=$(virsh net-dumpxml kubepg | grep -oP "ip address='\K\d+\.\d+.\d+")


mkdir -p ~/.kubepg
script_dir=$(dirname $0)
TARGET=${kubepg_net}.11

node_list=""
for i in $(seq 1 6)
do
    new_node=${kubepg_net}.1${i}
    node_list="${node_list} ${new_node}"
done

KEY="-i ~/.kubepg/kubepg_id"
scp $KEY ${script_dir}/../kubespray/install.sh root@$TARGET:kubespray-install.sh
scp $KEY ~/.kubepg/kubepg_id root@$TARGET:
ssh $KEY root@$TARGET -- bash kubespray-install.sh ${node_list}
scp $KEY root@$TARGET:~/.kube/config ~/.kubepg/kubeconfig
export KUBECONFIG=~/.kubepg/kubeconfig

echo "A kubeconfig file for the cluster is available at: ~/.kubepg/kubeconfig"
echo
echo You can setup kubectl to use your cluster using:
echo
echo "   export KUBECONFIG=~/.kubepg/kubeconfig"
echo
kubectl cluster-info
