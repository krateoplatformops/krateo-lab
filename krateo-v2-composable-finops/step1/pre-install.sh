#!/bin/bash
echo "apiVersion: v1
kind: Namespace
metadata:
  name: krateo-system
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: webservice-api-mock-deployment
  namespace: krateo-system
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
  namespace: krateo-system
spec:
  selector:
    app: webservice-api-mock
  type: NodePort
  ports:
  - protocol: TCP
    port: 8080
    targetPort: 8080
---
apiVersion: v1
kind: Secret
metadata: 
  name: webservice-mock-endpoint
  namespace: krateo-system
stringData:
  server-url: http://<host>:<port>" > webserver-mock.yaml
    
kubectl apply -f webserver-mock.yaml

kubectl taint nodes controlplane node-role.kubernetes.io/control-plane:NoSchedule-

helm repo add krateo https://charts.krateo.io
helm repo update krateo
helm upgrade installer installer \
  --repo https://charts.krateo.io \
  --namespace krateo-system \
  --create-namespace \
  --install \
  --version 2.4.2 \
  --set krateoplatformops.composablefinops.enabled=true \
  --set krateoplatformops.composableoperations.enabled=false \
  --set krateoplatformops.composableportal.enabled=false \
  --wait