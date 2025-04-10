## Let's prepare the toolchain managed by Krateo

```plain
helm install github-provider krateo/github-provider --namespace krateo-system --create-namespace --wait
helm install git-provider krateo/git-provider --namespace krateo-system --create-namespace --wait
curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
rm argocd-linux-amd64
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update argo
helm install argocd argo/argo-cd --namespace krateo-system --create-namespace --set server.service.type=NodePort --set server.service.nodePortHttp=30086 --wait
kubectl patch configmap argocd-cm -n krateo-system --patch '{"data": {"accounts.krateo-account": "apiKey, login"}}'
kubectl patch configmap argocd-rbac-cm -n krateo-system --patch '{"data": {"policy.default": "role:readonly"}}'
PASSWORD=$(kubectl -n krateo-system get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
argocd login localhost:30086 --insecure --username admin --password $PASSWORD
argocd account list
TOKEN=$(argocd account generate-token --account krateo-account)

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
type: Opaque
metadata:
  name: argocd-endpoint
  namespace: krateo-system
stringData:
  insecure: "true"
  server-url: https://argocd-server.krateo-system.svc:443
  token: $TOKEN
EOF
```{{exec}}

Add the github token:

```plain
read -s ACCESS_TOKEN
```{{exec}}

```plain
cat <<EOF | kubectl apply -f -
apiVersion: v1
stringData:
  token: $ACCESS_TOKEN
kind: Secret
metadata:
  name: github-repo-creds
  namespace: krateo-system
type: Opaque
EOF
```{{exec}}

## Add a Form to the Portal

A `CompositionDefinition` is a construct from Krateo’s [core-provider](https://github.com/krateoplatformops/core-provider/) that allows [Helm](https://helm.sh/) to become a native Kubernetes resource. What we propose as a platform is to implement infrastructure blueprints using Helm charts, which Krateo then takes and makes available within Kubernetes.
A `Composition` is essentially a Helm release, but it goes through Kubernetes' native validation process.
A Composition can be created either manually (using kubectl apply) or through a form in the Portal.

Let's add a `Card` and a `CustomForm` in order to add a form to the portal. In this case we're leveraging [Fireworksapp](https://github.com/krateoplatformops/krateo-v2-template-fireworksapp), our showcase example.

```plain
kubectl create ns fireworksapp-system
kubectl apply -f https://raw.githubusercontent.com/krateoplatformops/krateo-v2-template-fireworksapp/refs/tags/1.1.15/compositiondefinition.yaml
kubectl apply -f https://raw.githubusercontent.com/krateoplatformops/krateo-v2-template-fireworksapp/refs/tags/1.1.15/customform.yaml
```{{exec}}

Let's wait for the CompositionDefinition `fireworksapp` to be Ready

```plain
kubectl wait compositiondefinition fireworksapp --for condition=Ready=True --timeout=300s --namespace fireworksapp-system
```{{exec}}

Check the CompositionDefinition `fireworksapp` outputs, especially for the `RESOURCE` field.

```plain
kubectl get compositiondefinition fireworksapp --namespace fireworksapp-system
```{{exec}}

The `core-provider` has just generated:
* a Custom Resource Definition leveraging the values.json.schema file from the Helm chart:

```plain
kubectl get crd fireworksapps.composition.krateo.io -o yaml
```{{exec}}

* started a specific Deployment (which leverages the `composition-dynamic-controller` image) which will watch for new Custom Resources related to the generated CRD and the specific version.

```plain
kubectl get deployment fireworksapps-v1-1-15-controller --namespace fireworksapp-system
```{{exec}}
