## Let's configure the Krateo Composable FinOps Database Handler
Install the Database Handler, a proxy that allows the scrapers to upload data to the database using a simple HTTP REST API:
```plain
helm install finops-database-handler krateo/finops-database-handler -n finops --set service.type=NodePort
```{{exec}}

Let's create the Databricks database configuration custom resource:
```yaml
apiVersion: finops.krateo.io/v1
kind: DatabaseConfig
metadata:
  name: # DatabaseConfig name
  namespace: # DatabaseConfig namespace
spec:
  username: # username string
  passwordSecretRef: # object reference to secret with password
    name: # secret name
    namespace: # secret namespace
    key: # secret key
```

Run the following scripts to compile the database configuration and the secret with the CrateDB account's password:
```plain
./database-input.sh
kubectl apply -f token.yaml
kubectl apply -f database.yaml
```{{exec}}

Let's wait for the FinOps Database Handler to be ready:
```plain
kubectl wait deployment -n finops finops-database-handler --for condition=Available=True --timeout=300s
```{{exec}}
