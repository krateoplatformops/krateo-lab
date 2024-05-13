Let's install another `CompositionDefinition` pulling the `Composition` from a Helm repository.

```plain
cat <<EOF | kubectl apply -f -
apiVersion: core.krateo.io/v1alpha1
kind: CompositionDefinition
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

Let's wait for the CompositionDefinition `sample-repo` to be Ready

```plain
kubectl wait compositiondefinition sample-repo --for condition=Ready=True --timeout=300s --namespace krateo-system
```{{exec}}

Check the CompositionDefinition `sample-repo` outputs

```plain
kubectl get compositiondefinition sample-repo --namespace krateo-system
```{{exec}}

The `core-provider` has just generated:
* a Custom Resource Definition leveraging the values.json.schema file from the Helm chart:

```plain
kubectl get crd jenkins.composition.krateo.io
```{{exec}}

* started a specific Pod from the `composition-dynamic-controller` image which will watch for new Custom Resources related to the generated CRD and the specific version.

```plain
kubectl get deployment jenkins-v10-2-4-controller --namespace krateo-system
```{{exec}}
