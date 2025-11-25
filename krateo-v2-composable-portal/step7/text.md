## Check Form

Let's check the status of the `Form` `github-scaffolding-with-composition-page-form` resource:

```plain
curl -v "http://localhost:30081/call?apiVersion=widgets.templates.krateo.io%2Fv1beta1&name=github-scaffolding-with-composition-page-form-not-alphabetical-order&namespace=demo-system&resource=forms" \
  -H "Authorization: Bearer $adminAccessToken"
```{{exec}}

The status returns the Form and the relative schema. In Krateo, the Kubernetes RBAC is evaluated to populate the actions array.