# Update the Fireworksapp Chart in the `compositiondefinition`

1. Update the existing CompositionDefinition fireworksapp-cd in the fireworksapp-system namespace to change the spec.chart.version to 1.1.14:
```bash
kubectl patch compositiondefinition fireworksapp-cd -n fireworksapp-system --type=merge -p '{"spec":{"chart":{"version":"1.1.14"}}}'
```{{exec}}

2. Wait for the `fireworksapp-cd` CompositionDefinition to be in the `Ready=True` condition in the `fireworksapp-system` namespace:

```bash
kubectl wait compositiondefinition fireworksapp-cd --for condition=Ready=True --namespace fireworksapp-system --timeout=300s
```{{exec}}

3. Inspect the CustomResourceDefinition `fireworksapps.composition.krateo.io` to see the added version:

```bash
kubectl get crd fireworksapps.composition.krateo.io -o yaml
```{{exec}}

4. Check if the `fireworksapps-v1-1-14-controller` deployment to be ready in the `fireworksapp-system` namespace:

```bash
kubectl wait deployment fireworksapps-v1-1-14-controller --namespace fireworksapp-system --for condition=Available=True --timeout=300s
```{{exec}}

5. Check that the previously installed chart have the expected version: 

```bash
helm list -n fireworksapp-system
```{{exec}}

This procedure update the existing fireworksapp installations to use the new version `1.1.14` of the chart, since the `values.schema.json` does not change between the two versions.


## Automatic Deletion of Unused `composition-dynamic-controller` Deployments

Notice that the previously deployed instances (pods) of `composition-dynamic-controller` that were configured to manage resources of version 1.1.13 no longer exist in the cluster.

This is due to the automatic cleanup mechanism that removes older and unused deployments along with their associated RBAC resources from the cluster:

```bash
kubectl get po -n fireworksapp-system
```{{exec}}

This automatic cleanup helps maintain cluster cleaniness by removing outdated controller instances when they are no longer needed.

