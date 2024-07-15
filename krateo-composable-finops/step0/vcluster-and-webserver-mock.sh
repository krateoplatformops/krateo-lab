#!/bin/bash
curl -L -o vcluster "https://github.com/loft-sh/vcluster/releases/latest/download/vcluster-linux-amd64" && sudo install -c -m 0755 vcluster /usr/local/bin && rm -f vcluster
echo "vcluster:
  image: rancher/k3s:v1.30.2-k3s2
  extraArgs:
    - --kube-apiserver-arg
    - feature-gates=CustomResourceFieldSelectors=true" > vcluster.yaml
helm upgrade --install vcluster vcluster   --values vcluster.yaml   --repo https://charts.loft.sh   --namespace vcluster   --repository-config='' --create-namespace
echo "Installing VCluster. Please wait..."
kubectl rollout status --watch --timeout=600s statefulset/vcluster -n vcluster
sleep 5s
vcluster connect vcluster -n vcluster > /dev/null 2>&1  &
echo "apiVersion: v1
kind: Namespace
metadata:
  name: finops
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: webservice-api-mock-deployment
  namespace: finops
  labels:
    app: webservice-api-mock
spec:
  replicas: 1
  selector:
    matchLabels:
      app: webservice-api-mock
  template:
    metadata:
      labels:
        app: webservice-api-mock
    spec:
      containers:
      - name: webservice
        imagePullPolicy: Always
        image: ghcr.io/krateoplatformops/finops-webservice-api-mock:latest
        ports:
        - containerPort: 8080
---
apiVersion: v1
kind: Service
metadata:
  name: webservice-api-mock
  namespace: finops
spec:
  selector:
    app: webservice-api-mock
  type: NodePort
  ports:
  - protocol: TCP
    port: 8080
    targetPort: 8080" > webserver-mock.yaml
    
kubectl apply -f webserver-mock.yaml
echo "Installation complete!"
