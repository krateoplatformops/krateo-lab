## Let's install GitHub as Identity Provider

```plain
cat <<EOF | kubectl apply -f -
apiVersion: v1
data:
  clientSecret: YzRkZGRjNjk0NjYwNTc3NjBkNTU2Nzc1NzliMmM1Mzc1ZWJkOGViMw==
kind: Secret
metadata:
  name: github
  namespace: krateo-system
type: Opaque
---
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

And let's check again the authentication strategies available:

```plain
curl http://localhost:30007/strategies
```{{exec}}
