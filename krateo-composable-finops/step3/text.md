## Install Krateo Composable FinOps - operator-focus
Let's repeat the installation for one last operator, the FinOps operator-focus. This module is responsible for starting the exporting and scraping pipeline for static FOCUS costs. There will be an example later.

Deploy the operator:
```plain
helm install finops-operator-focus krateo/finops-operator-focus -n finops --version 0.3.1
```{{exec}}

Let's wait for the deployment to be available

```plain
kubectl wait deployment finops-operator-focus-controller-manager --for condition=Available=True --timeout=300s --namespace finops
```{{exec}}
