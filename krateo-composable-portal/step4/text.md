## Install Krateo Composable Portal frontend

Let's update the endpoint for our lab:

```plain
cat .env.development
```{{exec}}

```plain
sed -i 's/https:\/\/api.krateoplatformops.io/{{TRAFFIC_HOST1_30007}}/g' .env.development
```{{exec}}

```plain
cat .env.development
```{{exec}}

Let's start the frontend locally:

```plain
npm run dev
```{{exec}}
