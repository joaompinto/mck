# Download Rook

```sh
wget https://github.com/rook/rook/archive/v1.0.4.tar.gz
tar xvf v1.0.4.tar.gz
cd rook*
```

# Installing the Rook Common Objects & Operator
```sh
cd cluster/examples/kubernetes/ceph/
kubectl create -f common.yaml
kubectl create -f operator.yaml
kubectl create -f cluster.yaml
kubectl create -f storageclass.yaml
```

# Install the CEPH toolbox
```
kubectl create -f toolbox.yaml
```

# Check the cluster status
```sh
kubectl -n rook-ceph exec -it $(kubectl -n rook-ceph get pod -l "app=rook-ceph-tools" -o jsonpath='{.items[0].metadata.name}') bash
```

You can check from the toolbox with the following commands:
- ceph status
- ceph osd status
- ceph df
- rados df

# The following commands are avaialble: