## Add a Composition to the Portal via Template

Now we want to add a `Composition` to the Portal.

First of all, we need to prepare the toolchain that will be configured by the `Composition`.

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

echo "Please enter your GitHub personal access token:"
read -s ACCESS_TOKEN

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

In order to configure ArgoCD, we need to configure ArgoCD to generate a Token 

Let's apply a `template-chart` in order to add a Template to the portal.

```plain
helm upgrade fireworksapp template \
  --repo https://charts.krateo.io \
  --namespace fireworksapp-system \
  --create-namespace \
  --install \
  --wait \
  --version 0.1.0
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
kubectl get deployment fireworksapps-v1-1-8-controller --namespace fireworksapp-system
```{{exec}}
