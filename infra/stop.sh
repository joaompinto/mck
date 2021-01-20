#/bin/sh

for i in $(seq 1 6)
do
    virsh --connect=qemu:///system destroy kubepg-node${i}
done
