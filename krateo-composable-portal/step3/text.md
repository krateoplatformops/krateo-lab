## Install Krateo Composable Portal authn-service Helm chart
Now we install the chart

```plain
helm install authn-service krateo/authn-service --create-namespace --namespace krateo-system --version 0.7.2 -f values.yaml
```{{exec}}

Let's wait for the deployment to be Available

```plain
kubectl wait deployment authn-service  --for condition=Available=True --timeout=300s --namespace krateo-system
```{{exec}}

Let's patch the authn-service to expose it on a fixed port:

```plain
cat > servicetype.json << EOF
- op: replace
  path: "/spec/type"
  value: NodePort
EOF
kubectl patch svc authn-service -n krateo-system --type JSON --patch-file servicetype.json
cat > nodeport.json << EOF
- op: replace
  path: "/spec/ports/0/nodePort"
  value: 30007
EOF
kubectl patch svc authn-service -n krateo-system --type JSON --patch-file nodeport.json
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
curl http://localhost:30007/strategies
```{{exec}}

Now that there's a new basic user, let's try to login and check the response!

```plain
cd && curl http://localhost:30007/basic/login -H "Authorization: Basic Y3liZXJqb2tlcjoxMjM0NTY=" | jq -r .data > cyberjoker.kubeconfig
```{{exec}}

The authn-service response contains the kubeconfig for the user logged in.

```plain
cat cyberjoker.kubeconfig
```{{exec}}

This user has no Role enabled yet. Let's make an example: using the kubernetes-admin kubeconfig, let's get the list of all pods in the cluster:

```plain
export KUBECONFIG=/root/.kube/config
kubectl get secrets -n dev-system
```{{exec}}

We expect that the user 'cyberjoker' cannot access to pods:

```plain
export KUBECONFIG=/root/cyberjoker.kubeconfig
kubectl get secrets -n dev-system
```{{exec}}

Let's apply a Role to the 'cyberjoker' user, acting again as a kubernetes-admin user:

```plain
export KUBECONFIG=/root/.kube/config
kubectl apply -f /root/filesystem/role.yaml
```{{exec}}

Let's regenerate the kubeconfig for 'cyberjoker':
```plain
cd && curl http://localhost:30007/basic/login -H "Authorization: Basic Y3liZXJqb2tlcjoxMjM0NTY=" | jq -r .data > cyberjoker.kubeconfig
```{{exec}}

Let's check again if the user 'cyberjoker' can access to pods now:

```plain
export KUBECONFIG=/root/cyberjoker.kubeconfig
kubectl get secrets -n dev-system
```{{exec}}
