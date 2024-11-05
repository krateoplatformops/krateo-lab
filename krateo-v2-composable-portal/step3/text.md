## Add a Template to the portal

Now we want to add a Template to the Portal.

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
