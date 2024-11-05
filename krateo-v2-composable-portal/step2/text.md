Let's check the authentication strategies available:

```plain
curl http://localhost:30082/strategies
```{{exec}}

[You can also access it externally]({{TRAFFIC_HOST1_30082}}/strategies)

By default, the Krateo installer deploys an initial configuration of the portal based on [composable-portal-basic](https://github.com/krateoplatformops/composable-portal-basic/).
In this chart, an `admin` user is configured.

Let's retrieve the password:

```plain
kubectl get secret admin-password  -n krateo-system -o jsonpath="{.data.password}" | base64 -d
```{{exec}}

Let's open [Krateo Composable Portal]({{TRAFFIC_HOST1_30080}}) with the credentials retrieved.

Let's try now to login via terminal!

```plain
token=$(echo -n "admin:$(kubectl get secret admin-password -n krateo-system -o jsonpath="{.data.password}" | base64 -d)" | base64)
cd && curl http://localhost:30082/basic/login -H "Authorization: Basic $token" | jq -r .data > admin.kubeconfig
```{{exec}}

The authn response contains the kubeconfig for the user logged in.

```plain
cat admin.kubeconfig | jq
```{{exec}}