## Let's customize the Portal (1/2)

Now that we have deployed our first Composition, let's try to customize the Portal following this [tutorial](https://docs.krateo.io/how-to-guides/write-frontend/simple-page-guide).

### Create a namespace for our widgets.

```plain
kubectl create ns simple-guide
```{{exec}}

## Creating a Button widget.

The creation of a Button widget is as simple as applying a yaml a kind of type Button with the required properties inside `spec.widgetData`. (widgetData validation is run when doing an apply to make sure required properties are present)

```plain
cat <<EOF | kubectl apply -f -
kind: Button
apiVersion: widgets.templates.krateo.io/v1beta1
metadata:
  name: simple-guide-button
  namespace: simple-guide
spec:
  widgetData:
    icon: fa-sun
    label: My Custom Button
    clickActionId: none
    actions: {}
EOF
```{{exec}}

To verify the widget has been correctly created, run

```plain
kubectl get button -n  simple-guide
```{{exec}}

## Showing the Button widget in a new Page

The Button widget is correctly created in the cluster, but in order for it to be visible is needs to be references by another visible widget.

We will insert the `Button` in a new `Page` widget.

```plain
cat <<EOF | kubectl apply -f -
kind: Page
apiVersion: widgets.templates.krateo.io/v1beta1
metadata:
  name: simple-guide-page
  namespace: simple-guide
spec:
  widgetData:
    allowedResources:
      - buttons
    items:
      - resourceRefId: simple-button-id # <- this need to match the id of and item in spec.resourcesRefs
  resourcesRefs:
    items:
      - id: simple-button-id
        apiVersion: widgets.templates.krateo.io/v1beta1
        name: simple-guide-button # <- matches metadata.name of the button widgetw e created
        namespace: simple-guide
        resource: buttons
        verb: GET
EOF
```{{exec}}

By examining the previous yaml we can see that we referenced our Button by name in `spec.resourcesRefs.items[0]` and added an id (`simple-button-id`).

Declaring resurces in `spec.resourcesRefs` is the way Krateo knows to load these widgets, they can be declare manually like in our case or dynamically (see `resourcesRefsTemplate` section in [docs](https://github.com/krateoplatformops/frontend/blob/main/docs/docs.md) for more info.) This concept is generic to any widget and is used to load other resources.

## Where is the Page?

We have created a `Button` and a `Page` that references the `Button` but nothing is yet visible in the UI.

### Creating a new link in the sidebar

We need a way to navigato to this page, to do so we will create a `NavMenuItem` that point reference the newly created page by running

```plain
cat <<EOF | kubectl apply -f -
kind: NavMenuItem
apiVersion: widgets.templates.krateo.io/v1beta1
metadata:
  name: simple-guide-nav-menu-item
  namespace: simple-guide
spec:
  widgetData:
    allowedResources:
      - pages
    resourceRefId: page-id # <- reference the id of a widget declared below in spec.resourcesRefs
    label: Guide New Page
    icon: fa-sun
    path: /simple-guide
    order: 90 # <- this is used to order the item in the menu, anything with a lower order will be placed before this one
  resourcesRefs:
    items:
      - id: page-id
        apiVersion: widgets.templates.krateo.io/v1beta1
        name: simple-guide-page # <- matches metadata.name of the page widget we created in the previous step
        namespace: simple-guide
        resource: pages
        verb: GET
EOF
```{{exec}}

Now refreshing the page will show the newly navigation item in the sidebar.

### Visiting the new page

Clicking to the new sidebar menu will navigate to the path declared in the `NavMenuItem` `spec.widgetData.path` property and finally display our `Button` widget!

## Recap

We created a hierarchy or widget declaratively
`NavMenuItem` -> `Page` -> `Button`

- Widgets load other widgets via by referencing them inside `spec.resourcesRefs` and display them by using referencing the `resourcesRef` id inside `spec.widgetData`

## Testing the declarative nature of widgets

Try editing the `spec.label` prop of the yaml file in `guide-simple-button.yaml` or `guide-simple-navmenuitem.yaml` and apply the changes.

```plain
cat <<EOF | kubectl apply -f -
kind: Button
apiVersion: widgets.templates.krateo.io/v1beta1
metadata:
  name: simple-guide-button
  namespace: simple-guide
spec:
  widgetData:
    icon: fa-sun
    label: I was updated
    clickActionId: none
    actions: {}
---
kind: NavMenuItem
apiVersion: widgets.templates.krateo.io/v1beta1
metadata:
  name: simple-guide-nav-menu-item
  namespace: simple-guide
spec:
  widgetData:
    allowedResources:
      - pages
    resourceRefId: page-id # <- reference the id of a widget declared below in spec.resourcesRefs
    label: Updated link
    icon: fa-sun
    path: /simple-guide
    order: 90 # <- this is used to order the item in the menu, anything with a lower order will be placed before this one
  resourcesRefs:
    items:
      - id: page-id
        apiVersion: widgets.templates.krateo.io/v1beta1
        name: simple-guide-page # <- matches metadata.name of the page widget we created in the previous step
        namespace: simple-guide
        resource: pages
        verb: GET
EOF
```{{exec}}

After a refresh of the page you'll be able to see the changes reflected in the UI.
## Next steps

A `Button` that does nothing is not very useful, in the next guide we will see how to update the `Button` to trigger an action on click.