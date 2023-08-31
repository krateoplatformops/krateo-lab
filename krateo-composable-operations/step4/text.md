
What happens when we try to update the `Definition` `sample-repo`?

```plain
kubectl patch definition sample-repo --namespace krateo-system -p '{"spec":{"chart":{"version": "10.2.5"}}}' --type=merge
```{{exec}}

We will the following error:

```plain
The Definition "sample-repo" is invalid: spec.chart.version: Invalid value: "string": Version is immutable
```

A `Definition` cannot be changed once created. If the user is willing to create a new Custom Resource Definition once a new version of the Helm chart is available, a new `Definition` should be created.
