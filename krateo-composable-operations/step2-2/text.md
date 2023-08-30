
Let's install another `Definition` pulling the Helm chart as an OCI artifact.

<br>

```plain
cat <<EOF | kubectl apply -f -
apiVersion: core.krateo.io/v1alpha1
kind: Definition
metadata:
  name: sample-oci
  namespace: krateo-system
spec:
  chart:
    url: oci://registry-1.docker.io/bitnamicharts/redis
    version: 18.0.1
EOF
```{{exec}}

Let's wait for the Definition `sample-oci` to be Ready

```plain
kubectl wait definition sample-oci --for condition=Ready=True --timeout=300s --namespace krateo-system
```{{exec}}

Check the Definition `sample-oci` outputs

```plain
kubectl get definition sample-oci --namespace krateo-system
```{{exec}}

The `core-provider` has just generated:
* a Custom Resource Definition leveraging the values.json.schema file from the Helm chart:

```plain
kubectl get crd | grep redis
```{{exec}}

* started a specific Pod from the `composition-dynamic-controller` image which will watch for new Custom Resources related to the generated CRD.

```plain
kubectl get pods --namespace krateo-system | grep redis
```{{exec}}
