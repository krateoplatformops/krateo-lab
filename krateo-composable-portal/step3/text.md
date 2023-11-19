## Install Krateo Composable Portal authn-service Helm chart
Now we install the chart

```plain
helm install authn-service krateo/authn-service --create-namespace --namespace krateo-system --version 0.5.1 -f values.yaml
```{{exec}}

Let's wait for the deployment to be Available

```plain
kubectl wait deployment authn-service  --for condition=Available=True --timeout=300s --namespace krateo-system
```{{exec}}


Let's install GitHub as Identity Provider

```plain
cat <<EOF | kubectl apply -f -
apiVersion: oauth.authn.krateo.io/v1alpha1
kind: GithubConfig
metadata:
  name: github
spec:
  authStyle: 0
  authURL: https://github.com/login/oauth/authorize
  clientID: 77fcb37e2373f49fa771
  clientSecretRef:
    key: clientSecret
    name: github
    namespace: krateo-system
  organization: krateoplatformops
  redirectURL: https://localhost:5173/auth/github
  scopes:
  - read:user
  - read:org
  tokenURL: https://github.com/login/oauth/access_token
EOF
```{{exec}}

Let's patch the authn-service to expose it on a fixed port:

```plain
- op: replace
  path: "/spec/ports/0/nodePort"
  value: 30007
EOF
```{{exec}}

Let's check the authentication strategies available:

```plain
curl http://localhost:30007/strategies
```{{exec}}

[You can also access it externally]({{TRAFFIC_HOST1_30007}}/strategies)

Let's configure a basic authentication:

```plain
cat <<EOF | kubectl apply -f -
apiVersion: v1
data:
  password: MTIzNDU2
kind: Secret
metadata:
  name: pixelprincess-password
  namespace: krateo-system
type: kubernetes.io/basic-auth
EOF
```{{exec}}

And let's check again the authentication strategies available:

```plain
curl http://localhost:30007/strategies
```{{exec}}
