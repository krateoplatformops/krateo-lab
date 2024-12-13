## Install Krateo Composable FinOps - operator-scraper
Second, install the FinOps operator-scraper. This module is responsible for starting the Prometheus scrapers.

Deploy the operator:
```plain
helm install finops-operator-scraper krateo/finops-operator-scraper -n finops --version 0.3.1 --set env.URL_DB_WEBSERVICE=http://finops-database-handler.finops:8088
```{{exec}}

Let's wait for the deployment to be available

```plain
kubectl wait deployment finops-operator-scraper-controller-manager --for condition=Available=True --timeout=300s --namespace finops
```{{exec}}
