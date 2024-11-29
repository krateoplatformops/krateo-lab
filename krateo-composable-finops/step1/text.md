## Install Krateo Composable FinOps - operator-exporter
First, install the FinOps operator-exporter. This module is responsible for starting the Prometheus endpoint exporters and the respective scrapers.

Deploy the operator:
```plain
helm repo add krateo https://charts.krateo.io
helm repo update krateo
helm install finops-operator-exporter krateo/finops-operator-exporter -n finops --create-namespace --version 0.3.1
```{{exec}}

Let's wait for the deployment to be available

```plain
kubectl wait deployment finops-operator-exporter-controller-manager --for condition=Available=True --timeout=300s --namespace finops
```{{exec}}
