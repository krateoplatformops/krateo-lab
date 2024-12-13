#!/bin/bash
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
