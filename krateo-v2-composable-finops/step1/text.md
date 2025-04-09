## Install Krateo and the Composable FinOps
To install Krateo and the Composable FinOps module, we will follow the [official Krateo Documentation](https://docs.krateo.io/how-to-guides/install-krateo/installing-krateo-kind).

```plain
helm repo add krateo https://charts.krateo.io
helm repo update krateo
helm upgrade installer installer \
  --repo https://charts.krateo.io \
  --namespace krateo-system \
  --create-namespace \
  --install \
  --version 2.4.1 \
  --set krateoplatformops.finopscratedbcustomresource.resources.disk.storageClass=local-path \
  --set krateoplatformops.finopsoperatorcratedb.env.CRATEDB_OPERATOR_DEBUG_VOLUME_STORAGE_CLASS=local-path \
  --wait
```{{exec}}

Wait for Krateo to be ready:
```plain
kubectl wait krateoplatformops krateo --for condition=Ready=True --namespace krateo-system --timeout=660s
```{{exec}}
This step might take upwards of 10 minutes, go grab a coffee in the meantime! :)