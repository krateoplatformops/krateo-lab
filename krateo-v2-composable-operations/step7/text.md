# How to Have Different Versions of the Same Composition Installed

With the approach explained on the previous page, you cannot have two versions of the same composition running in the same cluster because the `core-provider` will automatically update older charts to the new version.

To work around this limitation, you can apply a `CompositionDefinition` manifest that installs version 1.1.13 of the chart in the `fireworksapp-system` namespace:

```bash
cat <<EOF | kubectl apply -f -
apiVersion: core.krateo.io/v1alpha1
kind: CompositionDefinition
metadata:
  annotations:
    krateo.io/connector-verbose: "true"
  name: fireworksapp-cd-copy
  namespace: fireworksapp-system
spec:
  chart:
    repo: fireworks-app
    url: https://charts.krateo.io
    version: 1.1.13
EOF
```{{exec}}

## Verify the Installation

1. Wait for the `CompositionDefinition` to be ready:
   ```bash
   kubectl wait compositiondefinition fireworksapp-cd-copy --for condition=Ready=True --timeout=600s --namespace fireworksapp-system
   ```{{exec}}

2. Check the specific Deployment that uses the `composition-dynamic-controller` image. This deployment monitors new Custom Resources related to the generated CRD and the specific version:
   ```bash
   kubectl get deployment fireworksapps-v1-1-13-controller --namespace fireworksapp-system
   ```{{exec}}

## Configure the Composition

Now you can create an instance of the composition.

Before proceeding, update the references to the GitHub organization where the repository will be created:

1. Open the Killercoda IDE and navigate to the following file:
   ```
   /root/filesystem/fireworksapp-composition-values-copy.yaml
   ```
2. Modify the `spec.toRepo.org` field to include your GitHub organization name.
3. Apply the updated manifest:
   ```bash
   kubectl apply -f /root/filesystem/fireworksapp-composition-values-copy.yaml
   ```{{exec}}

## Verify the Installation of the Composition

1. Wait for the Composition to be ready:
   ```bash
   kubectl wait fireworksapp fireworksapp-composition-copy --for condition=Ready=True \
     --timeout=600s --namespace fireworksapp-system
   ```{{exec}}

2. Verify that the previously installed charts have the expected versions:
   ```bash
   helm list -n fireworksapp-system
   ```{{exec}}

At this point, you should see two charts: one at version 1.1.14 and the other at version 1.1.13.

## Update the Newly Created Composition to 1.1.14

1. Update the existing composition `fireworksapp-composition-copy` to version 1.1.14:
   ```bash
   kubectl patch fireworksapp fireworksapp-composition-copy \
     -n fireworksapp-system \
     --type=merge \
     -p '{"metadata":{"labels":{"krateo.io/composition-version":"v1-1-14"}}}'
   ```{{exec}}

## Verify the Installation of the Updated Composition

1. Wait for the Composition to be ready:
   ```bash
   kubectl wait fireworksapp fireworksapp-composition-copy --for condition=Ready=True \
     --timeout=600s --namespace fireworksapp-system
   ```{{exec}}

2. Verify that the previously installed charts have the expected versions:
   ```bash
   helm list -n fireworksapp-system
   ```{{exec}}