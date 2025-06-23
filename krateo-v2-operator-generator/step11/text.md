# How to Create the webservice 

## Create the Web Service for TeamRepo Management

At this point, we need to implement a web service that handles API calls to the GitHub API. In this case, the web service will only be responsible for the `get` operation for teamrepos, because the `create`, `delete`, and `update` operations are handled directly by the controller.

To handle this case, we've implemented a web service that handles the `get` operation for teamrepos. You can check the implementation at this link: [GitHub Plugin for rest-dynamic-controller](https://github.com/krateoplatformops/github-rest-dynamic-controller-plugin/blob/main/internal/handlers/repo/repo.go). You can also check the [README](https://github.com/krateoplatformops/github-rest-dynamic-controller-plugin/blob/main/README.md) for more information on running and why it has been implemented.

**Note:** `rest-dynamic-controller` to check if the CR is up-to-date or not, checks the fields in the CR (spec and status) against the fields in the response body from the external API. It compare the fields at the same level, so if the response fields are more nested than the fields in the CR, it will not be able to compare them correctly. This is why we need to implement a web service that returns the response body with the same structure as the CR. This problem is quite common and a specific solution has been described [here](https://github.com/krateoplatformops/github-rest-dynamic-controller-plugin/blob/main/README.md#2-get-team-permission-in-a-repository)

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
          image: ghcr.io/krateoplatformops/github-rest-dynamic-controller-plugin:0.0.2
          ports:
            - containerPort: 8080
EOF
```{{exec}}

## Update the RestDefinition to Use the Web Service

Now we need to tell the `rest-dynamic-controller` to use the web service to handle the `get` operation for teamrepos. We can do this by adding the plugin URL to the OpenAPI specification of the `teamrepo` RestDefinition. We can accomplish this by adding the `servers` field to the endpoint in the OpenAPI specification (https://swagger.io/docs/specification/v3_0/api-host-and-base-path/#overriding-servers). In this case, the URL will be `http://github-provider-plugin-krateo.default.svc.cluster.local:8080` because the web service is running in the `default` namespace with the service name `github-provider-plugin-krateo`.

Let's create a new configmap with the updated OpenAPI specification:

```bash
kubectl create configmap teamrepo-ws --from-file=/root/filesystem/teamrepo_ws.yaml -n gh-system
```{{exec}}

As you can see, the new OpenAPI specification also includes another endpoint for the `get` operation that points to the web service URL:

```yaml
...
paths:
  "/teamrepository/orgs/{org}/teams/{team_slug}/repos/{owner}/{repo}":
    get:
      servers:
      - url: http://github-provider-plugin-krateo.default.svc.cluster.local:8080
...
```

This means that when the `rest-dynamic-controller` handles the `get` operation for teamrepos, it will call the web service instead of the GitHub API directly. The web service will then add the necessary headers to the request and return the response body.

## Update the RestDefinition to Use the New ConfigMap

Now we need to update the `RestDefinition` to use the new configmap:

```bash
cat <<EOF | kubectl apply -f -
apiVersion: swaggergen.krateo.io/v1alpha1
kind: RestDefinition
metadata:
  name: gh-teamrepo
  namespace: gh-system
spec:
  oasPath: configmap://gh-system/teamrepo-ws/teamrepo_ws.yaml
  resourceGroup: github.kog.krateo.io
  resource: 
    kind: TeamRepo
    identifiers:
      - id
      - permissions
      - html_url
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

## Check the TeamRepo Status

We expect the controller to update the RestDefinition and start using the web service to handle the `get` operation for teamrepos.
At this point, the `rest-dynamic-controller` should be able to handle the `get` operation for teamrepos using the web service. You can check the status of the TeamRepo resource by running:

```bash
kubectl describe teamrepo.github.kog.krateo.io/test-teamrepo -n gh-system
```{{exec}}

You should see that the message field is now empty, which means the RestDefinition is ready and correctly observed by the controller.

## Update the TeamRepo Permission

To check if the remote resource changes along with the custom resource, you can run the following command to change the teamrepo's permission:

```bash
cat <<EOF | kubectl apply -f -
apiVersion: github.kog.krateo.io/v1alpha1
kind: TeamRepo
metadata:
  name: test-teamrepo
  namespace: gh-system
spec:
  authenticationRefs:
    bearerAuthRef: gh-bearer
  org: krateoplatformops-test
  owner: krateoplatformops-test
  team_slug: prova
  repo: test-teamrepo
  permission: pull
EOF
```{{exec}}

After a few seconds, you should see that the teamrepo's permission is updated in GitHub (notest that GitHub Web map 'pull' permission to 'read'). Check the teamrepo status by running:

```bash
kubectl describe teamrepo.github.kog.krateo.io/test-teamrepo -n gh-system
```{{exec}}

You should see that the permission is updated to `pull`, the status is set to `Ready`: `True`, and events indicate that the external resource was updated successfully:

```text
Events:
  Type     Reason                         Age                  From  Message
  ----     ------                         ----                 ----  -------
  Normal   UpdatedExternalResource        77s (x2 over 80s)             Successfully requested update of external resource
```

## Delete the Custom Resource

To delete the teamrepo, you can delete the `TeamRepo` custom resource:

```bash
kubectl delete teamrepo.github.kog.krateo.io test-teamrepo -n gh-system
```

This will trigger the controller to delete the corresponding teamrepo in GitHub.

You should see an event for the TeamRepo resource indicating that the external resource was deleted successfully. Check the deletion status by running:

```bash
kubectl get events --sort-by='.lastTimestamp' -n gh-system | grep teamrepo/test-teamrepo
```

```text
Events:
  Type     Reason                         Age                  From  Message
  ----     ------                         ----                 ----  -------
  Normal   DeletedExternalResource      teamrepo/test-teamrepo        Successfully requested deletion of external resource
```

This indicates that the teamrepo was deleted successfully from GitHub. You can manually check the GitHub UI to confirm that the teamrepo is no longer present.