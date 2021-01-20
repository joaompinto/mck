# Kubernetes Play Ground Setup 

This repository provides scripts that can be used to setup a kubernetes playground using libvirt.

## Motivation

If you are searching for the easiest/quickest option to get a local hosted Kubernetes cluster for experimentation, the best options are [minikube](https://kubernetes.io/docs/tasks/tools/install-minikube/), [minishift](https://docs.okd.io/latest/minishift/getting-started/installing.html) or [k3s](https://k3s.io/). Mini*/k3s are great for testing, they are packaged/installed using custom methods which were optimized for an easy/quick experience but which are very different from the methods that you would use to install a production kubernetes cluster.

There are several vagrant-based projects that work nice for production-alike environment, but they mostly rely on VirtualBox and/or Vagrant specific features that you will not use in a production deployment. KubePG leverages he same libvirt/kvm that you are likely to find on opensource based virtualizaion providers, and uses [kubespray](https://github.com/kubernetes-sigs/kubespray) which you might also be using for production deployments.

## Requirements

- Linux system with Libvirt/KVM setup (per your distribution instructions)
- 12+ GB RAM
- 120GB Disk Space
- Internet (outbound) network connectivity
- virt-install
- patience (the install may took from 2h to 3h depending on your hardware and internet connection)

It is being tested on Fedora 30 and Ubuntu 19.04, it should work with most modern Linux distributions.

## Features

- Kubernetes v1.15.3 (installed via kubespray)
- 3 master nodes + 3 worker nodes

## Options
- Load balanced services using MetalLB: _kubernetes/install-loadbalancer.sh_


## Install

### Download ISO
Execute the script to download the CentOS ISO required for the VMs install

```sh
utils/download-iso.sh
```

### Create the VMs

Execute the infrastructure script providing a private ip network range, this range will be used internally on your host, it must not overlap with an existing network range.

```
# Use 192.168.8.1 for our kubernetes virtual infrastructure default network
sudo infra/create.sh 192.168.8.1/24
```

### NGINX Ingress
```
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/mandatory.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/provider/cloud-generic.yaml
kubectl -n ingress-nginx get svc
```

## Uninstall

You can destroy the related nodes using:
```sh
infra/stop.sh
sudo infra/destroy.sh
```
###


## References:

- https://www.cyberciti.biz/faq/how-to-install-kvm-on-centos-7-rhel-7-headless-server/

- https://earlruby.org/2018/12/setting-up-a-personal-production-quality-kubernetes-cluster-with-kubespray/

