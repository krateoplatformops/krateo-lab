# Composition Deletion

Now, what happens when you delete a Composition? You might expect that the related Helm chart will be removed from the cluster. This is exactly what happens when we run the following command:

```bash
kubectl delete fireworksapps fireworksapp-composition-1 -n fireworksapp-system
```{{exec}}

Let's verify if the release is still installed in the cluster:

```bash
helm list -n fireworksapp-system
```{{exec}}

As you can see there is no more a `fireworksapp-composition-1` installed in the cluster!