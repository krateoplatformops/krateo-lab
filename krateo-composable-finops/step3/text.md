## Install Krateo Composable FinOps - operator-scraper
Let's repeat the installation for one last operator, the FinOps operator-focus. This module is responsible for starting the exporting and scraping pipeline for static FOCUS costs. There will be an example later.

Download the repository:
```plain
cd ..
git clone https://github.com/krateoplatformops/finops-operator-focus.git
cd finops-operator-focus
```{{exec}}

Deploy the operator:
IMG is the image of the operator. REPO indicates where to get the exporter/scraper images.
```plain
make deploy IMG=ghcr.io/krateoplatformops/finops-operator-focus:0.1.0 REPO=ghcr.io/krateoplatformops/
```{{exec}}

Let's wait for the deployment to be available

```plain
kubectl wait deployment operator-focus-controller-manager --for condition=Available=True --timeout=300s --namespace operator-focus-system
```{{exec}}