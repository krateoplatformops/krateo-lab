## Check Panel to retrieve the Form

To interact with the snowplow APIs, we need to authenticate to auth, retrieve the token and use it to authenticated.

Let's retrieve the token:

```plain
adminToken=$(echo -n "admin:$(kubectl get secret admin-password -n krateo-system -o jsonpath="{.data.password}" | base64 -d)" | base64)
adminAccessToken=$(curl -s http://localhost:30082/basic/login -H "Authorization: Basic $adminToken" | jq -r .accessToken)
```{{exec}}

Let's check the status of the `Panel` `github-scaffolding-with-composition-page-panel` resource:

```plain
curl -v "http://localhost:30081/call?apiVersion=widgets.templates.krateo.io%2Fv1beta1&name=github-scaffolding-with-composition-page-panel&namespace=demo-system&resource=panels" \
  -H "Authorization: Bearer $adminAccessToken"
```{{exec}}


The status returns the possible actions available for the user requesting the `Panel`. In Krateo, the Kubernetes RBAC is evaluated to populate the `status.resourcesRefs` array.
Focus on it.

What happens when we try to retrieve the `Panel` as `cyberjoker` user?

```plain
cyberjokerToken=$(echo -n "cyberjoker:$(kubectl get secret cyberjoker-password -n krateo-system -o jsonpath="{.data.password}" | base64 -d)" | base64)
cyberjokerAccessToken=$(curl -s http://localhost:30082/basic/login -H "Authorization: Basic $cyberjokerToken" | jq -r .accessToken)

curl -v "http://localhost:30081/call?apiVersion=widgets.templates.krateo.io%2Fv1beta1&name=github-scaffolding-with-composition-page-panel&namespace=demo-system&resource=panels" \
  -H "Authorization: Bearer $cyberjokerAccessToken"
```{{exec}}

Focus again on the `status.resourcesRefs` array.


## Bonus question

Why we didn't just use this command?

```plain
kubectl get panel github-scaffolding-with-composition-page-panel --namespace demo-system -o yaml --kubeconfig admin.kubeconfig
```{{exec}}

Because `snowplow` generates at runtime the status of the resource. 