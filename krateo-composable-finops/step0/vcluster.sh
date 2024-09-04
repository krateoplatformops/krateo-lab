#!/bin/bash
curl -L -o vcluster "https://github.com/loft-sh/vcluster/releases/download/v0.20.0/vcluster-linux-amd64" && sudo install -c -m 0755 vcluster /usr/local/bin && rm -f vcluster
echo "controlPlane:
  distro:
    k3s:
      enabled: true
      extraArgs:
      - --kube-apiserver-arg
      - feature-gates=CustomResourceFieldSelectors=true
      image:
        tag: v1.30.2-k3s2
  statefulSet:
    scheduling:
      podManagementPolicy: OrderedReady" > vcluster.yaml
helm upgrade --install vcluster vcluster   --values vcluster.yaml   --repo https://charts.loft.sh   --namespace vcluster   --repository-config='' --create-namespace
echo "Installing VCluster. Please wait..."
kubectl rollout status --watch --timeout=600s statefulset/vcluster -n vcluster
