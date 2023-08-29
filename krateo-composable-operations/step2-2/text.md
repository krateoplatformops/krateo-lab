
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
