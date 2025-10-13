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
  --version 2.6.0 \
  --wait
helm upgrade installer installer \
  --repo https://charts.krateo.io \
  --namespace krateo-system \
  --install \
  --version 2.6.0 \
  --set krateoplatformops.composablefinops.enabled=true \
  --set krateoplatformops.composableoperations.enabled=false \
  --set krateoplatformops.composableportal.enabled=false \
  --wait