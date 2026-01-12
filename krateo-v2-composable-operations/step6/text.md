# Pause Composition Reconciliation

If, for some reason, you need to pause the reconciliation of a composition in any Krateo provider, including the `composition-dynamic-controller`, you can do so by adding the annotation `"krateo.io/paused"` with the value `true`.

For example, to stop the reconciliation of the last created composition `gh-scaffolding-composition-2`, run the following command:

```bash
kubectl annotate githubscaffolding gh-scaffolding-composition-2 -n ghscaffolding-system "krateo.io/paused=true"
```{{exec}}

To check if the annotation is paused, run:

```bash
kubectl get events -n ghscaffolding-system --sort-by='.metadata.creationTimestamp' | grep "gh-scaffolding-composition-2"
```{{exec}}

You should probably retry some time before the event is generated.
To resume the reconciliation, remove the annotation:

```bash
kubectl annotate githubscaffolding gh-scaffolding-composition-2 -n ghscaffolding-system "krateo.io/paused-"
```{{exec}}

# Composition Deletion

What happens when you delete a Composition? You might expect that the related Helm chart will be removed from the cluster. This is exactly what happens when you run the following command:

```bash
kubectl delete githubscaffoldings gh-scaffolding-composition-1 -n ghscaffolding-system
```{{exec}}

To verify if the release is still installed in the cluster, run:

```bash
helm list -n ghscaffolding-system
```{{exec}}

As you can see, the `gh-scaffolding-composition-1-<random>` is no longer installed in the cluster!