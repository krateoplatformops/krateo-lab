## Let's configure CrateDB
In this step, we will configure a new CrateDB cluster. To begin, create a persistent volume claim to store CrateDB's data:
```plain
echo "apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: local-path-pvc
  namespace: default
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: local-path
  resources:
    requests:
      storage: 2Gi" > pvc.yaml
kubectl apply -f pvc.yaml
```{{exec}}

Install the CrateDB operator:
```plain
helm repo add crate-operator https://crate.github.io/crate-operator
helm repo update
helm install crate-operator crate-operator/crate-operator --namespace crate-operator --create-namespace --set env.CRATEDB_OPERATOR_DEBUG_VOLUME_STORAGE_CLASS=local-path
```{{exec}}

Then, create the CR for the CrateDB operator to initialize the database:
```plain
echo "apiVersion: cloud.crate.io/v1
kind: CrateDB
metadata:
  name: cratedb-cluster
  namespace: finops
spec:
  cluster:
    imageRegistry: crate
    name: crate-dev
    version: 5.9.2
  nodes:
    data:
    - name: hot
      replicas: 1
      resources:
        limits:
          cpu: 0.5
          memory: 1Gi
        disk:
          count: 1
          size: 1000MiB
          storageClass: local-path
        heapRatio: 0.25" > dev-cluster.yaml
kubectl apply -f dev-cluster.yaml
```{{exec}}

Wait for the database to be ready:
```plain
kubectl wait pod crate-data-hot-cratedb-cluster-0 -n finops --for condition=Ready=True --timeout=600s
```{{exec}}
This step can take a long time.
