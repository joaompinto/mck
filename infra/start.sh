#/bin/sh

for i in $(seq 1 6)
do
    virsh --connect=qemu:///system start kubepg-node${i}
done
