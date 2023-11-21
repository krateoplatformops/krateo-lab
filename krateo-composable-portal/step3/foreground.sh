echo "Preparing authn-service Helm values..."

cd

git clone --branch 0.7.2 https://github.com/krateoplatformops/authn-service-chart

cd authn-service-chart/chart

export AUTHN_KUBECONFIG_CACRT=$(cat /etc/kubernetes/pki/ca.crt | base64 | tr -d '[:space:]')

sed -i "s|\/tmp\/ca.crt|${AUTHN_KUBECONFIG_CACRT}|" values.yaml

file_path="/.kube/config"
variable_name="clusters[0].cluster.server"

# Extract the value of the variable from the file
variable_value=$(grep "$variable_name" "$file_path" | awk '{print $2}')

# Export the value to an environment variable
export MY_SERVER_VARIABLE="$variable_value"

# Print the exported value (optional)
echo "Exported variable: MY_SERVER_VARIABLE=$variable_value"
