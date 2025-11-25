# Exploring the Krateo Composition Resource

The Krateo Composition resource is the main entry point for managing deployments created by the `core-provider`. Let's take a closer look at the resource.

## Inspecting a Composition Instance

First, let's examine the `gh-scaffolding-composition-1` Composition:

```bash
kubectl get githubscaffolding gh-scaffolding-composition-1 --namespace ghscaffolding-system -o yaml | yq
```{{exec}}

This will display the full YAML representation of the Composition resource.

### The Status

- The `managed` array lists all the Kubernetes resources that have been created by the Composition.
- Each item in the `managed` array includes the resource's `apiVersion`, `resource`, `name`, and `namespace`.
- This provides a comprehensive view of all the resources that make up the deployed application.

## Inspecting Another Composition Instance

Let's also look at the `gh-scaffolding-composition-2` Composition:

```bash
kubectl get githubscaffolding gh-scaffolding-composition-2 --namespace ghscaffolding-system -o yaml | yq
```{{exec}}

This will show the details of the second Composition instance.

## Understanding the Composition Resource

The Krateo Composition resource serves as a single point of control for managing deployed applications. By inspecting the `managed` array in the `Status` section, you can gain a comprehensive understanding of the resources that make up each deployed application.

This centralized view and management of the deployed application's resources is a key benefit of using the Krateo `core-provider` and Composition resources.

At this point, we can also see that at any action performed with the lifecycle of the Compositions, an event is thrown:

```bash
kubectl get events --sort-by='.lastTimestamp' -n ghscaffolding-system
```{{exec}}