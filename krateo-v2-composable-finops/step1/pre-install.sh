#!/bin/bash

cd /

kubectl apply -f mock-webserver.yaml
kubectl apply -f eventrouter-registration-crd.yaml

kubectl taint nodes controlplane node-role.kubernetes.io/control-plane:NoSchedule-

helm repo add krateo https://charts.krateo.io
helm repo update krateo
helm upgrade installer-crd installer-crd \
  --repo https://charts.krateo.io \
  --namespace krateo-system \
  --create-namespace \
  --install \
  --version 2.7.0 \
  --wait
helm upgrade installer installer \
  --repo https://charts.krateo.io \
  --namespace krateo-system \
  --install \
  --version 2.7.0 \
  --set krateoplatformops.composablefinops.enabled=false \
  --set krateoplatformops.eventsse.etcd.resources.requests.cpu="250m" \
  --set krateoplatformops.eventsse.etcd.resources.requests.memory="512Mi" \
  --set krateoplatformops.eventsse.etcd.resources.limits.memory="1Gi" \
  --set krateoplatformops.eventsse.etcd.persistence.size="6Gi" \
  --set krateoplatformops.eventsse.etcd.quotaBackendBytes="3221225472" \
  --set krateoplatformops.composablefinops.enabled=true \
  --set krateoplatformops.composableoperations.enabled=false \
  --set krateoplatformops.composableportal.enabled=false \
  --wait