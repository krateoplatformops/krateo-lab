
Now we're getting serious! Let's install a `Composition` leveraging the `fireworksapp-tgz` CompositionDefinition.

Following the [README.me](https://github.com/krateoplatformops/krateo-v2-template-fireworksapp/blob/5a625b21d23f32eda3b03f1706b2eabb67810caa/README.md) let's prepare the Kubernetes cluster:

```plain
helm repo add krateo https://charts.krateo.io
helm repo update krateo
helm install github-provider krateo/github-provider --namespace krateo-system --create-namespace
helm install git-provider krateo/git-provider --namespace krateo-system --create-namespace
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update argo
helm install argocd argo/argo-cd --namespace krateo-system --create-namespace --wait
```{{exec}}

In order to interact with GitHub, we need a token. Let's change the token in the file /root/filesystem/github-repo-creds.yaml
using Killercoda IDE.

Once the manifest is modified, let's apply the manifest:

```plain
kubectl apply -f /root/filesystem/github-repo-creds.yaml
```{{exec}}

We are now able to create an instance of the composition.

<br>

```plain
kubectl apply -f /root/filesystem/fireworksapp-composition-values.yaml
```{{exec}}

Let's wait for the Composition `fireworksapp` to be Ready

```plain
kubectl wait fireworksapp fireworksapp-tgz --for condition=Ready=True --timeout=300s --namespace krateo-system
```{{exec}}

Check the Composition `fireworksapp-tgz` outputs

```plain
kubectl get fireworksapp fireworksapp-tgz --namespace krateo-system
```{{exec}}
