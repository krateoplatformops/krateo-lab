## Install Krateo Composable Portal krateo-gateway Helm chart
Now we install the chart

```plain
helm install authn-service krateo/authn-service --create-namespace --namespace krateo-system --version 0.5.0 --set podEnv[5].value=$AUTHN_KUBECONFIG_CA_CERT
```{{exec}}

Let's wait for the deployment to be Available

```plain
kubectl wait deployment authn-service  --for condition=Available=True --timeout=300s --namespace krateo-system
```{{exec}}


Let's install GitHub as Identity Provider

```plain
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
```{{exec}}
