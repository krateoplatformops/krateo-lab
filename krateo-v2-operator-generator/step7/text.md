### Implementing the Fix
Since the controller can only perform one API call per action, the above solution isn't feasible. Instead, the recommended approach is to develop a simple webservice that handles this issue and returns the expected result to the controller.

You can find a reference implementation of this webservice written in Python 3 in the [github-oas3-plugin repository](https://github.com/krateoplatformops/github-oas3-plugin/blob/main/README.md). You can write the webservice in any programming language you prefer - check out the [oasgen-provider documentation](https://github.com/krateoplatformops/oasgen-provider/blob/main/README.md#how-to-write-a-webservice) for more examples.

For this lab, we'll use a Docker image of the [github-oas3-plugin](https://github.com/krateoplatformops/github-oas3-plugin) to deploy the webservice in the Killercoda Kubernetes cluster. Note that while this webservice can be deployed outside the cluster, it must be accessible by the controller to handle requests.

### Building the Webservice
```bash
kubectl run github-plugin --image=ghcr.io/krateoplatformops/github-oas3-plugin:0.0.1 --expose --port=8080 -n krateo-system
```

This command:
1. Creates a Pod named "github-plugin" running the webservice
2. Creates a Service with the same name to expose the Pod within the cluster
3. Makes the webservice accessible via the service name "github-plugin" on port 8080 in the krateo-system namespace


Check for pod readyness
```bash
kubectl wait po github-plugin --for condition=Ready=True --namespace krateo-system --timeout=300s
```{{exec}}
