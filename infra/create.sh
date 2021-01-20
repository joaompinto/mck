#!/bin/sh

set -eu


network=$1
homedir=$(egrep "^${USERNAME}:" /etc/passwd|cut -d":" -f6)

function cdr2mask () {
    # Number of args to shift, 255..255, first non-255 byte, zeroes
    set -- $(( 5 - ($1 / 8) )) 255 255 255 255 $(( (255 << (8 - ($1 % 8))) & 255 )) 0 0 0
    [ $1 -gt 1 ] && shift $1 || shift
    echo ${1-0}.${2-0}.${3-0}.${4-0}
}

function create_libvirt_network() {
    network=$(echo $1| cut -d"/" -f1)
    netmask=$(cdr2mask $(echo $1| cut -d"/" -f2))
    echo $network $netmask
    cp etc/networks/kubepg.xml tmp
    sed -i "s~%NETWORK%~${network}~g" tmp/kubepg.xml
    sed -i "s~%NETMASK%~${netmask}~g" tmp/kubepg.xml
    virsh net-define tmp/kubepg.xml
    virsh net-start kubepg
    virsh net-autostart kubepg
    virsh net-list
}


export LIBVIRT_DEFAULT_URI=qemu:///system
create_libvirt_network $1

# Generate an SSH key pair for the post install deployment
mkdir -p ${homedir}/.kubepg/
chown ${USERNAME}:${USERNAME} ${homedir}/.kubepg/
ssh-keygen -o -a 100 -t ed25519 -f ${homedir}/.kubepg/kubepg_id -P ""
chown ${USERNAME}:${USERNAME} ${homedir}/.kubepg/kubepg_id
public_key=$(cat ${homedir}/.kubepg/kubepg_id.pub)
kubepg_net=$(virsh net-dumpxml kubepg | grep -oP "ip address='\K\d+\.\d+.\d+")

# Create the first vm
i=1
sed "s~%NEW_SSH_KEY%~${public_key}~g" etc/centos7-minimal.ks.cfg > tmp/centos7-minimal.ks.cfg.tmp
sed -i "s~%GW%~${kubepg_net}.1~g" tmp/centos7-minimal.ks.cfg.tmp
sed -i "s~%IP%~${kubepg_net}.1${i}~g" tmp/centos7-minimal.ks.cfg.tmp
sed -i "s~%HOSTNAME%~kubepg-node${i}~g" tmp/centos7-minimal.ks.cfg.tmp
utils/create-kubepg-vm.sh -n kubepg-node${i} \
    -i tmp/CentOS-7-x86_64-Minimal-1908.iso \
    -k tmp/centos7-minimal.ks.cfg.tmp \
    -r 2048 \
    -c 2 \
    -s 20 \
    -b kubepg-br \
    -d

virsh destroy kubepg-node1

# Create the VMs
for i in $(seq 2 6)
do
    virt-clone --original kubepg-node1 --name kubepg-node${i} \
        --file /var/lib/libvirt/images/kubepg-node${i}.img \
        --file /var/lib/libvirt/images/kubepg-node${i}_1.img
    virt-sysprep -d kubepg-node${i} --hostname kubepg-node${i} \
        --run-command "sed -i s/${kubepg_net}.11/${kubepg_net}.1${i}/g /etc/sysconfig/network-scripts/ifcfg-eth0" \
        --operations defaults,-ssh-userdir
    virsh start kubepg-node${i}
done
virsh start kubepg-node1
utils/deploy-ssh-config.sh

echo You can now login into the node1 VM using:
echo
echo "  ssh kubepg-node1"
echo
echo or deploy the Kubernetes cluster using:
echo
echo "  kubernetes/deploy.sh"
echo 
