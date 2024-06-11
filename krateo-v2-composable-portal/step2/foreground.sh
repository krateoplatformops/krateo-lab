echo "Preparing krateo-gateway-chart Helm values..."

git clone --branch 0.1.3 --depth 1 https://github.com/krateoplatformops/krateo-gateway-chart

cd krateo-gateway-chart/chart

export KRATEO_GATEWAY_CACRT=$(cat /etc/kubernetes/pki/ca.crt | base64 | tr -d '[:space:]')

sed -i "s|\/tmp\/ca.crt|${KRATEO_GATEWAY_CACRT}|" values.yaml

export KRATEO_GATEWAY_CAKEY=$(cat /etc/kubernetes/pki/ca.key | base64 | tr -d '[:space:]')

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: krateo-gateway
  namespace: krateo-system
type: Opaque
stringData:
  KRATEO_GATEWAY_CAKEY: $KRATEO_GATEWAY_CAKEY
EOF
