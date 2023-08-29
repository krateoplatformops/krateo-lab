
Let's install another `Definition` pulling the Helm chart from a Helm repository.

<br>

```plain
cat <<EOF | kubectl apply -f -
apiVersion: core.krateo.io/v1alpha1
kind: Definition
metadata:
  name: sample-repo
  namespace: krateo-system
spec:
  chart:
    url: https://charts.bitnami.com/bitnami
    version: 12.8.3
    repo: postgresql
EOF
```{{exec}}

Let's wait for the Definition `sample-repo` to be Ready

```plain
kubectl wait definition sample-repo --for condition=Ready=True --timeout=300s --namespace krateo-system
```{{exec}}

Check the Definition `sample-repo` outputs

```plain
kubectl get definition sample-repo --namespace krateo-system
```{{exec}}
