## Install Krateo Composable FinOps - operator-scraper
Second, install the FinOps operator-scraper. This module is responsible for starting the Prometheus scrapers.

Download the repository:
```plain
cd ..
git clone https://github.com/krateoplatformops/finops-operator-scraper.git
cd finops-operator-scraper
```{{exec}}

Deploy the operator:
IMG is the image of the operator. REPO indicates where to get the exporter/scraper images.
```plain
make deploy IMG=ghcr.io/krateoplatformops/finops-operator-scraper:0.1.0 REPO=ghcr.io/krateoplatformops/
```{{exec}}

Let's wait for the deployment to be available

```plain
kubectl wait deployment operator-scraper-controller-manager --for condition=Available=True --timeout=300s --namespace operator-scraper-system
```{{exec}}
