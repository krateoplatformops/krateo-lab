## Install Krateo Composable FinOps - operator-scraper
Second, install the FinOps operator-scraper. This module is responsible for starting the Prometheus scrapers.

Deploy the operator:
```plain
helm repo add krateo https://charts.krateo.io
helm repo update krateo
helm install scraper krateo/finops-operator-scraper -n finops
```{{exec}}

Let's wait for the deployment to be available

```plain
kubectl wait deployment scraper-finops-operator-scraper-controller-manager --for condition=Available=True --timeout=300s --namespace finops
```{{exec}}
