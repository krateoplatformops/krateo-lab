## Let's navigate the Portal to find the Blueprint Card

Now that everything is ready, let's navigate through the [Portal]({{TRAFFIC_HOST1_30080}}).

Let's retrieve the password:

```plain
kubectl get secret admin-password  -n krateo-system -o jsonpath="{.data.password}" | base64 -d
```{{exec}}

Krateo Portal is preconfigured to open by default the `Dashboard` page.

Now we want to deploy a Composition.

If we navigate to the `Blueprints` page, we can find that there is the `Panel` we saw in the previous section.

Let's try to deploy it!