Let's install another `CompositionDefinition` pulling the `Composition` as an OCI artifact.

```plain
cat <<EOF | kubectl apply -f -
apiVersion: core.krateo.io/v1alpha1
kind: CompositionDefinition
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
kubectl wait compositiondefinition sample-oci --for condition=Ready=True --timeout=300s --namespace krateo-system
```{{exec}}

Check the CompositionDefinition `sample-oci` outputs

```plain
kubectl get compositiondefinition sample-oci --namespace krateo-system
```{{exec}}

The `core-provider` has just generated:
* a Custom Resource Definition leveraging the values.json.schema file from the Helm chart:

```plain
kubectl get crd redis.composition.krateo.io
```{{exec}}

* started a specific Deployment (which leverages the `composition-dynamic-controller` image) which will watch for new Custom Resources related to the generated CRD and the specific version.

```plain
kubectl get deployment redis-v18-0-1-controller --namespace krateo-system
```{{exec}}
