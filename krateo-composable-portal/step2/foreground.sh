echo "Preparing krateo-gateway-chart Helm values..."

git clone --branch 0.0.2 https://github.com/krateoplatformops/krateo-gateway-chart

cd krateo-gateway-chart/chart

sed 's/tmp\/ca.crt/etc\/kubernetes\/pki\/ca.crt/g' values.yaml
sed 's/tmp\/ca.key/etc\/kubernetes\/pki\/ca.key/g' values.yaml
