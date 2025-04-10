## Let's navigate the Portal to find the Template Card

Now that everything is ready, let's navigate through the [Portal]({{TRAFFIC_HOST1_30082}}/strategies).

Let's retrieve the password:

```plain
kubectl get secret admin-password  -n krateo-system -o jsonpath="{.data.password}" | base64 -d
```{{exec}}

Krateo Portal is preconfigured to open by default the `Compositions` page.
This behavior is configured by configuring the related Route: https://github.com/krateoplatformops/composable-portal-basic/blob/0.5.2/chart/templates/widgets.compositions-route.yaml#L14

Now we want to deploy a Composition.

If we navigate to the `Template` page, we can find that there is the `Card` we saw in the previous section.