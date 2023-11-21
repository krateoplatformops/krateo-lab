echo "Preparing authn-service Helm values..."

cd

git clone --branch 0.7.2 https://github.com/krateoplatformops/authn-service-chart

cd authn-service-chart/chart

export AUTHN_KUBECONFIG_CACRT=$(cat /etc/kubernetes/pki/ca.crt | base64 | tr -d '[:space:]')

sed -i "s|\/tmp\/ca.crt|${AUTHN_KUBECONFIG_CACRT}|" values.yaml

# Set the file path and variable name
file_path="/root/.kube/config"

# Extract the value of the variable from the file
variable_value=$(yq eval '.clusters[0].cluster.server' "$file_path")

# Export the value to an environment variable
export SERVER_VARIABLE="$variable_value"

sed -i "s|https:\/\/kube-apiserver:6443|${AUTHN_KUBERNETES_URL}|" values.yaml
