```sh
kubectl apply -k github.com/zalando/postgres-operator/manifests
kubectl apply -f storage/complete-postgres-manifest.yaml

PG_USER=$(kubectl get secret postgres.acid-test-cluster.credentials -o go-template='{{.data.username | base64decode}}')
PG_PASSWORD=$(kubectl get secret postgres.acid-test-cluster.credentials -o go-template='{{.data.password | base64decode}}')
PG_SERVICE=$(kubectl describe service acid-test-cluster | egrep "LoadBalancer Ingress"| cut -d: -f2|tr -d " ")
echo "$PG_SERVICE:5432:postgres:$PG_USER:$PG_PASSWORD" > ~/.pgpass
chmod 0600 ~/.pgpass
PGPASSFILE=~/.pgpass psql -h $PG_SERVICE  -U $PG_USER
```
# acid-test-cluster.default.svc.cluster.local
