## Install Krateo PlatformOps via installer Helm chart
First, we make sure we add the Krateo Helm charts repo to our Helm client

```plain
helm repo add krateo https://charts.krateo.io
```{{exec}}

```plain
read -s ACCESS_TOKEN
```{{exec}}


We can update the repo

```plain
helm repo update
```{{exec}}

Let's extract the server url of our Kubernetes cluster:

```plain
# Extract the value of the variable from the file
server_value=$(yq -r '.clusters[0].cluster.server' /root/.kube/config)

# Export the value to an environment variable
export KUBECONFIG_SERVER_URL="$server_value"
```{{exec}}

Now we install the chart

```plain
helm upgrade installer installer \
  --repo https://charts.krateo.io \
  --namespace krateo-system \
  --create-namespace \
  --install \
  --wait \
  --version 2.4.1 \
  --set krateoplatformops.authn.KUBECONFIG_SERVER_URL=$KUBECONFIG_SERVER_URL \
  --set krateoplatformops.frontend.overrideconf=true \
  --set krateoplatformops.frontend.config.AUTHN_API_BASE_URL="{{TRAFFIC_HOST1_30082}}" \
  --set krateoplatformops.frontend.config.BACKEND_API_BASE_URL="{{TRAFFIC_HOST1_30081}}" \
  --set krateoplatformops.frontend.config.EVENTS_PUSH_API_BASE_URL="{{TRAFFIC_HOST1_30083}}" \
  --set krateoplatformops.frontend.config.EVENTS_API_BASE_URL="{{TRAFFIC_HOST1_30083}}"
```{{exec}}

Let's wait for Krateo PlatformOps to be Available:

```plain
kubectl wait krateoplatformops krateo --for condition=Ready=True --timeout=660s --namespace krateo-system
```{{exec}}