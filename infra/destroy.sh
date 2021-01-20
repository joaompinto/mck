#/bin/sh
homedir=$(egrep "^${USERNAME}:" /etc/passwd|cut -d":" -f6)
export LIBVIRT_DEFAULT_URI=qemu:///system

for i in $(seq 1 6)
do
    virsh undefine kubepg-node${i}
done

virsh net-destroy kubepg
virsh net-undefine kubepg

#sudo ifconfig kubepg-br down
#sudo brctl delbr kubepg-br

rm -f ${homedir}/.kubepg/kubepg_id*
rm -rf /var/lib/libvirt/images/kubepg-*

