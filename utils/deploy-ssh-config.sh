#!/bin/sh

export LIBVIRT_DEFAULT_URI=qemu:///system

kubepg_net=$(virsh net-dumpxml kubepg | grep -oP "ip address='\K\d+\.\d+.\d+")

[ ! -d ~/.ssh ] && mkdir -m700 ~/.ssh
[ ! -f ~/.ssh/config ] && echo >> ~/.ssh/config

for i in $(seq 1 6)
do
    host="kubepg-node${i}"
    sed -i 's/^Host/\n&/' ~/.ssh/config
    sed -i '/^Host '"$host"'$/,/^$/d;/^$/d' ~/.ssh/config
    cat << _EOF_ >> ~/.ssh/config
Host ${host}
    Hostname ${kubepg_net}.1${i}
    User root
    IdentityFile ~/.kubepg/kubepg_id

_EOF_
done
chmod 700 ~/.ssh/config


