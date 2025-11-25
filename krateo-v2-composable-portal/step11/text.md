## RESTAction

The `RESTAction` is a Krateo PlatformOps resource that enables users to **declaratively define one or more REST API calls** within Kubernetes.

It allows you to chain HTTP requests, handle dependencies between them, extract data, and use filters to process results — all through a Kubernetes-native manifest.

This approach is particularly useful for integrating external systems or Kubernetes APIs into workflows managed by Krateo PlatformOps.

> `RESTAction` defines one or more declarative HTTP (REST) calls that can optionally depend on other calls.

It allows you to orchestrate a chain of API requests across multiple endpoints using Kubernetes resources.

A `RESTAction` resource declaratively defines one or more HTTP calls (`spec.api`) that can depend on each other.

Each call can produce a JSON response that becomes part of a **shared global context**, enabling subsequent calls to reference previous results using **JQ expressions**, iterators, and filters.

To fully leverage these advanced capabilities — such as resolving JQ expressions, using custom JQ functions or modules, and managing interdependent API calls — the `RESTAction` must be executed through the `snowplow` service endpoint (`/call`).  

Only this endpoint implements the orchestration logic that:
- Executes all HTTP requests defined under `spec.api`, respecting their declared dependencies (`dependsOn`).
- Stores all API responses in a global JSON context.
- Evaluates and resolves any JQ expressions or iterators defined within the resource.
- Returns the computed output in the resource’s `status` field.

When a `RESTAction` is retrieved directly via Kubernetes (e.g. `kubectl get restaction <name>`), the resource is shown **as-is**, without JQ resolution or execution of any API calls.

## Example

Let's apply a `RESTAction` that retrieves `name`, `namespace` and `uid` of each pod in the kube-system namespace:

```plain
cat <<EOF | kubectl apply -f -
apiVersion: templates.krateo.io/v1
kind: RESTAction
metadata:
  annotations:
    "krateo.io/verbose": "false"
  name: kube-get
  namespace: demo-system
spec:
  api:
  - name: pods
    continueOnError: true
    errorKey: podsError
    path: "/api/v1/namespaces/kube-system/pods"
    filter: "[.items[] | .metadata.name]"
  - name: get
    continueOnError: true
    errorKey: getError
    dependsOn: 
      name: pods
      iterator: .[]
    path: ${ "/api/v1/namespaces/kube-system/pods/" + (.) }
    filter: ".metadata | {name: .name, namespace: .namespace, uid: .uid}"
```{{exec}}

What happens if I invoke the `/call` endpoint of snowplow on this RESTAction as `admin` user?

```plain
curl -v "http://localhost:30081/call?apiVersion=templates.krateo.io%2Fv1&name=kube-get&namespace=demo-system&resource=restactions" \
  -H "Authorization: Bearer $adminAccessToken"
```{{exec}}

What happens instead if I call it as `cyberjoker` user?

```plain
curl -v "http://localhost:30081/call?apiVersion=templates.krateo.io%2Fv1&name=kube-get&namespace=demo-system&resource=restactions" \
  -H "Authorization: Bearer $cyberjokerAccessToken"
```{{exec}}