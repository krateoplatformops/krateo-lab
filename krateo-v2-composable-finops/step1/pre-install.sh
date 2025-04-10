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
  --version 2.4.1 \
  --set krateoplatformops.finopscratedbcustomresource.resources.disk.storageClass=local-path \
  --set krateoplatformops.finopsoperatorcratedb.env.CRATEDB_OPERATOR_DEBUG_VOLUME_STORAGE_CLASS=local-path \
  --set krateoplatformops.composablefinops.enabled=true \
  --set krateoplatformops.composableportalbasic.enabled=false \
  --set krateoplatformops.frontend.chart.name=sleep-chart \
  --set krateoplatformops.frontend.chart.version=0.1.0 \
  --set krateoplatformops.frontend.chart.repository="https://francescol96.github.io/sleep-chart/" \
  --set krateoplatformops.frontend.chart.wait=false \
  --set krateoplatformops.backend.chart.name=sleep-chart \
  --set krateoplatformops.backend.chart.version=0.1.0 \
  --set krateoplatformops.backend.chart.repository="https://francescol96.github.io/sleep-chart/" \
  --set krateoplatformops.backend.chart.wait=false \
  --set krateoplatformops.backend.etcd.chart.name=sleep-chart \
  --set krateoplatformops.backend.etcd.chart.version=0.1.0 \
  --set krateoplatformops.backend.etcd.chart.repository="https://francescol96.github.io/sleep-chart/" \
  --set krateoplatformops.backend.etcd.chart.wait=false \
  --set krateoplatformops.coreprovider.chart.name=sleep-chart \
  --set krateoplatformops.coreprovider.chart.version=0.1.0 \
  --set krateoplatformops.coreprovider.chart.repository="https://francescol96.github.io/sleep-chart/" \
  --set krateoplatformops.coreprovider.chart.wait=false \
  --set krateoplatformops.chartInspector.chart.name=sleep-chart \
  --set krateoplatformops.chartInspector.chart.version=0.1.0 \
  --set krateoplatformops.chartInspector.chart.repository="https://francescol96.github.io/sleep-chart/" \
  --set krateoplatformops.chartInspector.chart.wait=false \
  --set krateoplatformops.oasgenprovider.chart.name=sleep-chart \
  --set krateoplatformops.oasgenprovider.chart.version=0.1.0 \
  --set krateoplatformops.oasgenprovider.chart.repository="https://francescol96.github.io/sleep-chart/" \
  --set krateoplatformops.oasgenprovider.chart.wait=false \
  --set krateoplatformops.patchprovider.chart.name=sleep-chart \
  --set krateoplatformops.patchprovider.chart.version=0.1.0 \
  --set krateoplatformops.patchprovider.chart.repository="https://francescol96.github.io/sleep-chart/" \
  --set krateoplatformops.patchprovider.chart.wait=false \
  --set krateoplatformops.resourcetreehandler.chart.name=sleep-chart \
  --set krateoplatformops.resourcetreehandler.chart.version=0.1.0 \
  --set krateoplatformops.resourcetreehandler.chart.repository="https://francescol96.github.io/sleep-chart/" \
  --set krateoplatformops.resourcetreehandler.chart.wait=false \
  --wait