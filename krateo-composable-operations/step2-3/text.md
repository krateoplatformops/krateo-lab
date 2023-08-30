
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
    url: https://charts.krateo.io
    version: 10.2.4
    repo: jenkins
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

The `core-provider` has just generated:
* a Custom Resource Definition leveraging the values.json.schema file from the Helm chart:

```plain
kubectl get crd | grep jenkins
```{{exec}}

* started a specific Pod from the `composition-dynamic-controller` image which will watch for new Custom Resources related to the generated CRD.

```plain
kubectl get pods --namespace krateo-system | grep jenkins
```{{exec}}
