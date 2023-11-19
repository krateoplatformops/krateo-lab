echo "Preparing authn-service Helm values..."

cd

git clone --branch 0.5.1 https://github.com/krateoplatformops/authn-service-chart

cd authn-service-chart/chart

sed -i 's/tmp\/ca.crt/etc\/kubernetes\/pki\/ca.crt/g' values.yaml
