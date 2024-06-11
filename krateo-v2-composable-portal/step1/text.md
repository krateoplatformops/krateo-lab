## Install Krateo Composable Portal krateo-bff Helm chart
First, we make sure we add the Krateo Helm charts repo to our Helm client

```plain
helm repo add krateo https://charts.krateo.io
```{{exec}}

We can update the repo

```plain
helm repo update
```{{exec}}

Let's extract the server url of our Kubernetes cluster:

```plain
# Set the file path and variable name
file_path="/root/.kube/config"

# Extract the value of the variable from the file
server_value=$(yq eval '.clusters[0].cluster.server' "$file_path")

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
  --version 0.3.1 \
  --set krateoplatformops.init.enabled=false \
  --set krateoplatformops.authn.KUBECONFIG_SERVER_URL=$KUBECONFIG_SERVER_URL \
  --set krateoplatformops.frontend.overrideconf=true \
  --set krateoplatformops.frontend.env.AUTHN_API_BASE_URL="{{TRAFFIC_HOST1_30082}}" \
  --set krateoplatformops.frontend.env.BFF_API_BASE_URL="{{TRAFFIC_HOST1_30081}}"
```{{exec}}

Let's wait for Krateo PlatformOps to be Available

```plain
kubectl wait krateoplatformops krateo --for condition=Ready=True --timeout=600s --namespace krateo-system
```{{exec}}

Let's open [Krateo Portal]({{TRAFFIC_HOST1_30080}}).
