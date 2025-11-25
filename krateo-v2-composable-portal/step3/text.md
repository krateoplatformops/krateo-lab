## Let's add a Blueprint to the Portal

```plain
helm repo add marketplace https://marketplace.krateo.io
helm repo update marketplace
helm install github-provider-kog-repo marketplace/github-provider-kog-repo --namespace krateo-system --create-namespace --wait --version 1.0.0
helm install git-provider krateo/git-provider --namespace krateo-system --create-namespace --wait --version 0.10.1

curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
rm argocd-linux-amd64

helm repo add argo https://argoproj.github.io/argo-helm
helm repo update argo
helm install argocd argo/argo-cd --namespace krateo-system --create-namespace --set server.service.type=NodePort --set server.service.nodePortHttp=30086 --wait --version 8.0.17

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

## Add a `Blueprint` to the Portal

A `Blueprint` is a reusable Helm Chart that includes a `values.schema.json` file. This schema allows Krateo to automatically generate user-friendly forms and validation rules in the Krateo Composable Portal, making complex configurations accessible and safe.

A `CompositionDefinition` is a construct from Krateo’s [core-provider](https://github.com/krateoplatformops/core-provider/) that allows a [Helm](https://helm.sh/) chart to become a native Kubernetes resource. What we propose as a platform is to implement infrastructure blueprints using Helm charts, which Krateo then takes and makes available within Kubernetes.

A `Composition` is essentially a Helm release, but it goes through Kubernetes' native validation process. It can be created either manually (using kubectl apply) or through a form in the Portal.

### Let's add the `Github Scaffolding With Composition Page` blueprint to the Portal

This is a Blueprint used to scaffold a toolchain to host and deploy a fully functional frontend App (FireworksApp).

This Blueprint implements the following steps:
1. Create an empty Github repository (on github.com) - [link](https://github.com/krateoplatformops-blueprints/github-scaffolding-with-composition-page/blob/main/chart/templates/git-repo.yaml)
2. Push the code from the [skeleton](https://github.com/krateoplatformops/krateo-v2-template-fireworksapp/tree/main/skeleton) to the previously create repository - [link](https://github.com/krateoplatformops/krateo-v2-template-fireworksapp/blob/main/chart/templates/git-clone.yaml)
3. A Continuous Integration pipeline (GitHub [workflow](https://github.com/krateoplatformops/krateo-v2-template-fireworksapp/blob/main/skeleton/.github/workflows/ci.yml)) will build the Dockerfile of the frontend app and the resulting image will be published as a Docker image on the GitHub Package registry
4. An ArgoCD Application will be deployed to listen to the Helm Chart of the FireworksApp application and deploy the chart on the same Kubernetes cluster where ArgoCD is hosted
5. The FireworksApp will be deployed with a Service type of NodePort kind exposed on the chosen port.
6. A composition page is available on Krateo Composable Portal

### Use the `portal-blueprint-page` blueprint

The `porta-blueprint-page` blueprint is an opinionanted blueprint to publish a blueprint into the Krateo Composable Portal. This blueprint is available [here](https://github.com/krateoplatformops-blueprints/portal-blueprint-page/tree/1.0.5).

```plain
cat <<EOF | kubectl apply -f -
apiVersion: core.krateo.io/v1alpha1
kind: CompositionDefinition
metadata:
  name: portal-blueprint-page
  namespace: krateo-system
spec:
  chart:
    repo: portal-blueprint-page
    url: https://marketplace.krateo.io
    version: 1.0.5
EOF
```{{exec}}

Let's wait for the CompositionDefinition `portal-blueprint-page` to be Ready

```plain
kubectl wait compositiondefinition portal-blueprint-page --for condition=Ready=True --timeout=300s --namespace krateo-system
```{{exec}}

Add the `github-scaffolding-with-composition-page` blueprint:

```plain
cat <<EOF | kubectl apply -f -
apiVersion: composition.krateo.io/v1-0-5
kind: PortalBlueprintPage
metadata:
  name: github-scaffolding-with-composition-page
  namespace: demo-system
spec:
  blueprint:
    url: https://marketplace.krateo.io
    version: 1.1.0 # this is the Blueprint version
    hasPage: true
  form:
    alphabeticalOrder: false
  panel:
    title: GitHub Scaffolding with Composition Page
    icon:
      name: fa-cubes
EOF
```{{exec}}

Let's wait for the CompositionDefinition `github-scaffolding-with-composition-page	` to be Ready

```plain
kubectl wait compositiondefinition github-scaffolding-with-composition-page	 --for condition=Ready=True --timeout=300s --namespace demo-system
```{{exec}}

Let's go back into the Portal in the Blueprints page.