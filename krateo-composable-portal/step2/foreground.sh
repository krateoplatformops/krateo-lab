echo "Preparing krateo-gateway-chart Helm values..."

git clone --branch 0.0.2 https://github.com/krateoplatformops/krateo-gateway-chart

cd krateo-gateway-chart/chart

sed -i 's/tmp\/ca.crt/etc\/kubernetes\/pki\/ca.crt/g' values.yaml
