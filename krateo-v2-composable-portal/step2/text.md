Let's check the authentication strategies available:

```plain
curl http://localhost:30082/strategies
```{{exec}}

[You can also access it externally]({{TRAFFIC_HOST1_30082}}/strategies)

Let's configure a basic authentication:

```plain
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
type: kubernetes.io/basic-auth
metadata:
  name: cyberjoker-password
  namespace: krateo-system
stringData:
  password: "123456"
---
apiVersion: basic.authn.krateo.io/v1alpha1
kind: User
metadata:
  name: cyberjoker
  namespace: krateo-system
spec:
  displayName: Cyber Joker
  avatarURL: https://i.pravatar.cc/256?img=70
  groups:
    - devs
  passwordRef:
    namespace: krateo-system
    name: cyberjoker-password
    key: password
EOF
```{{exec}}

And let's check again the authentication strategies available:

```plain
curl http://localhost:30082/strategies
```{{exec}}

Now that there's a new basic user, let's try to login and check the response!

```plain
cd && curl http://localhost:30082/basic/login -H "Authorization: Basic Y3liZXJqb2tlcjoxMjM0NTY=" | jq -r .data > cyberjoker.kubeconfig
```{{exec}}

The authn response contains the kubeconfig for the user logged in.

```plain
cat cyberjoker.kubeconfig | jq
```{{exec}}

Let's open again [Krateo Portal]({{TRAFFIC_HOST1_30080}}) and check if there's a new authentication form available. Login with username cyberjoker and password 123456.
