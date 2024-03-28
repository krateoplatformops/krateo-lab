## Install Krateo Composable FinOps - operator-exporter
First, install the FinOps operator-exporter. This module is responsible for starting the Prometheus endpoint exporters and the respective scrapers.

Download the repository:
```plain
git clone https://github.com/krateoplatformops/finops-operator-exporter.git
cd finops-operator-exporter
```{{exec}}

Deploy the operator:
IMG is the image of the operator. REPO indicates where to get the exporter/scraper images.
```plain
make deploy IMG=ghcr.io/krateoplatformops/finops-operator-exporter:0.1.0 REPO=ghcr.io/krateoplatformops/
```{{exec}}

Let's wait for the deployment to be available

```plain
kubectl wait deployment operator-exporter-controller-manager --for condition=Available=True --timeout=300s --namespace operator-exporter-system
```{{exec}}
