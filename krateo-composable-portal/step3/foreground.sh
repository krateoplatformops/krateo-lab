echo "Preparing krateo-gateway-chart Helm values..."

export AUTHN_KUBECONFIG_CA_CERT=$(cat /etc/kubernetes/pki/ca.crt | base64)
