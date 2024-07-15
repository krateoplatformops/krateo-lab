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
