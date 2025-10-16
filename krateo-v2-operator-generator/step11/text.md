# How to Create the webservice 

## Create the Web Service for TeamRepo Management

At this point, we need to implement a web service that handles API calls to the GitHub API. In this case, the web service will only be responsible for the `get` operation for teamrepos, because the `create`, `delete`, and `update` operations are handled directly by the controller without any additional processing.

To handle this case, we've implemented a web service that handles the `get` operation for teamrepos. You can check the implementation at this link: [GitHub Plugin for rest-dynamic-controller](https://github.com/krateoplatformops/github-rest-dynamic-controller-plugin/blob/main/internal/handlers/teamRepo/teamRepo.go). You can also check the [README](https://github.com/krateoplatformops/github-rest-dynamic-controller-plugin/blob/main/README.md) for more information on running and why it has been implemented.

**Note:** `rest-dynamic-controller` to check if the CR is up-to-date or not, checks the fields in the CR (spec and status) against the fields in the response body from the external API. **It compare the fields at the same level**, so if the response fields are more nested than the fields in the CR, it will not be able to compare them correctly. This is why we need to implement a web service that returns the response body with the same structure as the CR. This problem is quite common and a specific solution has been described [here](https://github.com/krateoplatformops/github-rest-dynamic-controller-plugin/blob/main/README.md#get-teamrepo-permission).

```bash
cat <<EOF | kubectl apply -f -
---
apiVersion: v1
kind: Service
metadata:
  name: github-provider-plugin-krateo
  namespace: default
spec:
  selector:
    app: github-provider-plugin-krateo
  ports:
    - protocol: TCP
      port: 8080
      targetPort: 8080
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: github-provider-plugin-krateo
  namespace: default
spec:
  replicas: 1
  selector:
    matchLabels:
      app: github-provider-plugin-krateo
  template:
    metadata:
      labels:
        app: github-provider-plugin-krateo
    spec:
      containers:
        - name: github-provider-plugin-krateo
          image: ghcr.io/krateoplatformops/github-rest-dynamic-controller-plugin:0.0.3
          ports:
            - containerPort: 8080
EOF
```{{exec}}