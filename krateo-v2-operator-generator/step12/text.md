
## Update the RestDefinition to Use the Web Service

Now we need to tell the `rest-dynamic-controller` to use the web service to handle the `get` operation for TeamRepoes. We can do this by adding the plugin URL to the OpenAPI specification of the `teamrepo` RestDefinition. 
We can accomplish this by adding the `servers` field to the endpoint in the OpenAPI specification (https://swagger.io/docs/specification/v3_0/api-host-and-base-path/#overriding-servers). 
In this case, the URL will be `http://github-provider-plugin-krateo.default.svc.cluster.local:8080` because the web service is running in the `default` namespace with the service name `github-provider-plugin-krateo`.

Let's create a new configmap with the updated OpenAPI specification:

```bash
kubectl create configmap teamrepo-ws --from-file=/root/filesystem/teamrepo_ws.yaml -n gh-system
```{{exec}}

As you can see, the new OpenAPI specification also includes another endpoint for the `get` operation that points to the web service URL:

```diff
...
paths:
  "/teamrepository/orgs/{org}/teams/{team_slug}/repos/{owner}/{repo}":
    get:
+     servers:
+     - url: http://github-provider-plugin-krateo.default.svc.cluster.local:8080
...
```

This means that when the `rest-dynamic-controller` handles the `get` operation for TeamRepoes, it will call the web service instead of the GitHub API directly. 
Note that this happens **just for the `get` operation**, while the other operations (`create`, `delete`, and `update`) will still call the GitHub API directly as defined in the original OpenAPI specification (`servers` field at the root level of the OAS).

The web service will then add the necessary headers to the request and return a processed response body that is compatible with the `rest-dynamic-controller`.

## Update the RestDefinition to Use the New ConfigMap

Now we need to update the `RestDefinition` to use the new configmap:

```bash
cat <<EOF | kubectl apply -f -
apiVersion: ogen.krateo.io/v1alpha1
kind: RestDefinition
metadata:
  name: gh-teamrepo
  namespace: gh-system
spec:
  oasPath: configmap://gh-system/teamrepo-ws/teamrepo_ws.yaml
  resourceGroup: github.ogen.krateo.io
  resource: 
    kind: TeamRepo
    additionalStatusFields:
      - id 
      - name
      - full_name
      - permission
    verbsDescription:
    - action: create
      method: PUT
      path: /orgs/{org}/teams/{team_slug}/repos/{owner}/{repo}
    - action: delete
      method: DELETE
      path: /orgs/{org}/teams/{team_slug}/repos/{owner}/{repo}
    - action: get
      method: GET
      path: /teamrepository/orgs/{org}/teams/{team_slug}/repos/{owner}/{repo}
    - action: update
      method: PUT
      path: /orgs/{org}/teams/{team_slug}/repos/{owner}/{repo}
EOF
```{{exec}}