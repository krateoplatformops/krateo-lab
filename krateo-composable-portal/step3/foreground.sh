echo "Preparing authn-service Helm values..."

cd

git clone --branch 0.7.1 https://github.com/krateoplatformops/authn-service-chart

cd authn-service-chart/chart

export AUTHN_KUBECONFIG_CA_CRT=$(cat /etc/kubernetes/pki/apiserver.crt | base64 | tr -d '[:space:]')

sed -i "s|\/tmp\/ca.crt|${AUTHN_KUBECONFIG_CA_CRT}|" values.yaml
