# Gracefully Pause a composition and its resources

## About the gracefullyPaused value

The `global.gracefullyPaused` value provides a way to gracefully pause both the composition resource and all Krateo resources within its Helm chart.

**How it works:**
- **Trigger**: Set the annotation krateo.io/gracefully-paused on the composition resource
- **Activation**: The pause takes effect only after the next successful Helm upgrade injects this value into the chart
- **Scope**: Pauses both the composition reconciliation AND any Krateo resources in the chart that respect the krateo.io/paused annotation

#### Use cases:
- **Graceful pause**: Temporarily halt all composition-related activity without resource deletion
- **Coordinated pause**: Ensure both the composition and its managed resources pause simultaneously
- **Safe maintenance**: Pause operations during maintenance windows

#### Comparison with `krateo.io/paused`:

| Annotation | Scope | When it takes effect |
|------------|-------|---------------------|
| `krateo.io/gracefully-paused` | Composition + chart resources | After next Helm upgrade |
| `krateo.io/paused` | Composition only | Immediately |

**Example**: Use `krateo.io/gracefully-paused` when you need to pause an entire application stack, or `krateo.io/paused` for immediate composition-only pausing.

More details on how to include the pause in a resource included in your chart in the [composition-dynamic-controller documentation](https://docs.krateo.io/key-concepts/kco/composition-dynamic-controller/#how-to-include-the-pause-in-a-resource-included-in-the-chart).

### Pause a Composition and its resources

To pause the reconciliation of a composition and all its resources, add the annotation `krateo.io/gracefully-paused` with the value `true`.

For example, to pause the reconciliation of the last created composition `gh-scaffolding-composition-2`, run the following command:

```bash
kubectl annotate githubscaffolding gh-scaffolding-composition-2 -n ghscaffolding-system "krateo.io/gracefully-paused=true"
```{{exec}}

To check if the annotation is paused, run:

```bash
kubectl get events -n ghscaffolding-system --sort-by='.metadata.creationTimestamp' | grep "gh-scaffolding-composition-2"
```{{exec}}

You should probably retry some time before the event is generated.

You can verify that the composition and its resources are paused by a resource installed by the composition, for example a `RepoConfiguration` resource:

Remember that you can find the list of resources created by a composition in the `status.managed` field of the composition:

```bash
kubectl get githubscaffolding gh-scaffolding-composition-2 -n ghscaffolding-system -o jsonpath='{.status.managed}' | jq
```{{exec}}

Let's check the `Repo` resource created by the composition:

```bash
kubectl get repoes $COMPOSITION_NAME_2-repo -n ghscaffolding-system -o jsonpath='{.metadata.annotations}' | jq
```{{exec}}

As you can see, the `krateo.io/paused` annotation is also applied to the `Repo` resource created by the composition.

Let's now check a resource that does not support the `krateo.io/paused` annotation, for example the `Application` resource for ArgoCD:

```bash
kubectl get applications $COMPOSITION_NAME_2 -n krateo-system -o jsonpath='{.metadata.annotations}' | jq
```{{exec}}

As you can see the `krateo.io/paused` annotation is not applied to the `Application` resource created by the composition, however the `spec.syncPolicy` field is set to `null`, effectively pausing the reconciliation of the application.

Check it out by running:

```bash
kubectl get applications $COMPOSITION_NAME_2 -n krateo-system -o jsonpath='{.spec.syncPolicy}' | jq
```{{exec}}

If you are interested in how we have implemented this behavior for the `Application` resource, check the [github-scaffolding chart template](https://github.com/krateoplatformops-blueprints/github-scaffolding/blob/693bfc1e057c11f73305f92f39ff4da01ddca8e6/blueprint/templates/argo-application.yaml#L18)

To resume the reconciliation, remove the annotation:

```bash
kubectl annotate githubscaffolding gh-scaffolding-composition-2 -n ghscaffolding-system "krateo.io/gracefully-paused-"
```{{exec}}

You can verify that the composition and its resources are resumed by checking again the `RepoConfiguration` resource:

```bash
kubectl get repoes $COMPOSITION_NAME_2-repo -n ghscaffolding-system -o jsonpath='{.metadata.annotations}' | jq
```{{exec}}

Remember that the edits can take some time to be propagated.




