Let's generate and deploy the Custom Resource Definition representing the `Composition` inspired by the Bitnami Postgresql Helm Chart using our `CompositionDefinition`. There are three possible ways to install it: via tgz archive, via oci artifact or via Helm repo. In this first example, we will pull directly the archive of the Helm chart.

```plain
cat <<EOF | kubectl apply -f -
apiVersion: core.krateo.io/v1alpha1
kind: CompositionDefinition
metadata:
  annotations:
     "krateo.io/connector-verbose": "true"
  name: fireworksapp-tgz
  namespace: krateo-system
spec:
  chart:
    url: https://github.com/krateoplatformops/krateo-v2-template-fireworksapp/releases/download/0.1.0/fireworks-app-0.1.0.tgz
EOF
```{{exec}}

Let's wait for the CompositionDefinition `fireworksapp-tgz` to be Ready

```plain
kubectl wait compositiondefinition fireworksapp-tgz --for condition=Ready=True --timeout=300s --namespace krateo-system
```{{exec}}

Check the CompositionDefinition `fireworksapp-tgz` outputs, especially for the `RESOURCE` field.

```plain
kubectl get compositiondefinition fireworksapp-tgz --namespace krateo-system
```{{exec}}

The `core-provider` has just generated:
* a Custom Resource Definition leveraging the values.json.schema file from the Helm chart:

```plain
kubectl get crd fireworksapps.composition.krateo.io -o yaml
```{{exec}}

* started a specific Deployment (which leverages the `composition-dynamic-controller` image) which will watch for new Custom Resources related to the generated CRD and the specific version.

```plain
kubectl get deployment fireworksapps-v0-1-0-controller --namespace krateo-system
```{{exec}}
