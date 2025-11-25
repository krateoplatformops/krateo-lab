# Widgets and RESTAction

In Krateo Composable Portal everything is based on the concept of widgets and their composition, a widget is a k8s CRD that maps to a UI element in the frontend (eg a Button) or to a configuration used by other widget (eg a Route)

[see all widgets](https://github.com/krateoplatformops/frontend/blob/main/docs/widgets-api-reference.md)

## Anatomy of a widget

A widget source of truth is a JSON schema that is used to generate a CRD, this allow each widget to have it's own Kind and schema validation at the moment of apply
example: [src/widgets/Button/Button.schema.json](/src/widgets/Button/Button.schema.json)

## widgetData

Every widget has a `widgetData` property that contains data used to control how the widget looks like or behave in the Frontend Composable Portal, in this example we are defining a `label`, an `icon` (using [fontawesome](https://fontawesome.com/search?ip=classic&s=solid&o=r) naming convention) and a `type` that control the the visual style of the button, in the button [API references](https://github.com/krateoplatformops/frontend/blob/main/docs/widgets-api-reference.md) can be seen all possible values.

Let's explore a basic Button widget

```
# button.yaml
kind: Button
apiVersion: widgets.templates.krateo.io/v1beta1
metadata:
  name: button-1
  namespace: demo-system
spec:
  widgetData:
    label: This is a button
    icon: fa-sun
    type: primary
```

## widgetDataTemplate

Every widget supports the property `spec.widgetDataTemplate` that allows overriding a specific value defined in `spec.widgetData`, this is useful to inject dynamic content inside a widget.

```
 widgetDataTemplate:
    - forPath: data
      expression: ${ .namespaces }
```

`widgetDataTemplate` accepts an array of objects with `forPath` and `expression` keys.

`forPath` is used to chose what key in `widgetData` to override, it uses dot notation to reference nested data eg `parentProperty.childProperty`

`expression` is a [jq](https://jqlang.org/) expression that uses the result of the jq expression as the data to be injected in the specified path

### Simple example

In the example below, the label of the button will be the date when the widget is loaded, as the data from widgetDataTemplate is substituted dynamically at the moment of loading a widget.

Let's try it:

```plain
kubectl apply -f - <<'YAML'
kind: Button
apiVersion: widgets.templates.krateo.io/v1beta1
metadata:
  name: button-post-nginx
  namespace: demo-system
spec:
  widgetData:
    actions: {}
    clickActionId: ""
    label: button 1
    icon: fa-rocket
    type: primary
  widgetDataTemplate:
    - forPath: label
      expression: ${ now | strftime("%Y-%m-%d") }
YAML
```{{exec}}

```plain
curl -v "http://localhost:30081/call?apiVersion=widgets.templates.krateo.io%2Fv1beta1&name=button-post-nginx&namespace=demo-system&resource=buttons" \
  -H "Authorization: Bearer $adminAccessToken"
```{{exec}}

### Complete example

Let's try a complete example!

```plain
kubectl apply -f - <<'YAML'
kind: Table
apiVersion: widgets.templates.krateo.io/v1beta1
metadata:
  name: table-of-namespaces
  namespace: demo-system
spec:
  widgetData:
    allowedResources: []
    pageSize: 10
    data: []
    columns:
      - valueKey: name
        title: Cluster Namespaces
  widgetDataTemplate:
    - forPath: data
      expression: >
        ${
          .namespaces
          | map([
              { valueKey: "name", kind:"jsonSchemaType", type:"string", stringValue:(.name // "") }
          ])
        }
  apiRef:
    name: cluster-namespaces
    namespace: demo-system
---
apiVersion: templates.krateo.io/v1
kind: RESTAction
metadata:
  name: cluster-namespaces
  namespace: demo-system
spec:
  api:
  - name: namespaces
    path: "/api/v1/namespaces"
    filter: "[.namespaces.items[] | {name: .metadata.name}]"
YAML
```{{exec}}

```plain
curl -v "http://localhost:30081/call?apiVersion=templates.krateo.io%2Fv1&name=cluster-namespaces&namespace=demo-system&resource=restactions" \
  -H "Authorization: Bearer $adminAccessToken"
```{{exec}}

```plain
curl -v "http://localhost:30081/call?apiVersion=widgets.templates.krateo.io%2Fv1beta1&name=table-of-namespaces&namespace=demo-system&resource=tables" \
  -H "Authorization: Bearer $adminAccessToken"
```{{exec}}

In the example above, we declared a table with a single column `name` to display all namespaces of the cluster.
The data is loaded directly from the k8s api server

### How does it work?

```
widgetDataTemplate:
    - forPath: data
      expression: ${ .namespaces }
```

What is `.namespaces`?

In the expression `.namespace` reference the result of an api called `namespaces`.

The Table widget has a field `spec.apiRef` that references a RESTAction by name (`cluster-namespaces`), an `api` with name `namespaces` is declared in the RESTAction's `spec.api` array

By this chain of references `Widget -> apiRef -> RESTAction -> api` widgetDataTemplate is able to refecence an api by name

```
apiVersion: templates.krateo.io/v1
kind: RESTAction
metadata:
  name: cluster-namespaces
  namespace: demo-system
spec:
  api:
  - name: namespaces
    path: "/api/v1/namespaces"
    filter: "[.items[] | {name: .metadata.name}]"
```

As shown above, the endpoint called is `/api/v1/namespaces` which call the k8s api server, if this were an absolute URL it could reference external APIs, see the [RESTActions documentation](./restactions.md) for more details and learning how to authenticate to external APIs