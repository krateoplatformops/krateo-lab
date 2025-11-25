## Add another user to the platform

Let's configure another user:

```plain
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
type: kubernetes.io/basic-auth
metadata:
  name: demolabuser-password
  namespace: krateo-system
stringData:
  password: "123456"
---
apiVersion: basic.authn.krateo.io/v1alpha1
kind: User
metadata:
  name: demolabuser
  namespace: krateo-system
spec:
  displayName: Demo Lab User
  avatarURL: https://i.pravatar.cc/256?img=62
  groups:
    - labs
  passwordRef:
    namespace: krateo-system
    name: demolabuser-password
    key: password
EOF
```{{exec}}

Now that there's a new basic user, let's try to login and check the response!

```plain
cd && curl http://localhost:30082/basic/login -H "Authorization: Basic Y3liZXJqb2tlcjoxMjM0NTY=" | jq -r .data > demolabuser.kubeconfig
```{{exec}}

The authn response contains the kubeconfig for the user logged in.

```plain
cat demolabuser.kubeconfig | jq
```{{exec}}