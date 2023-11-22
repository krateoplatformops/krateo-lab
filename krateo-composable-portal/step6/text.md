## Install Krateo Composable Portal frontend

Let's start the frontend locally:

```plain
docker run --env=VITE_GATEWAY_API_BASE_URL={{TRAFFIC_HOST1_30005}} --env=VITE_AUTHN_API_BASE_URL={{TRAFFIC_HOST1_30007}} -p 5173:5173 -d ghcr.io/krateoplatformops/krateo-frontend:latest
```{{exec}}

[Have fun!]({{TRAFFIC_HOST1_5173}})
