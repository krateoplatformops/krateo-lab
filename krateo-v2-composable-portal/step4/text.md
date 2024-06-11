## Add Krateo FormTemplate to retrieve the Composition

```plain
cat <<EOF | kubectl apply -f -
apiVersion: widgets.krateo.io/v1alpha1
kind: FormTemplate
metadata:
  name: fireworksapp-tgz
  namespace: demo-system
spec:
  compositionDefinitionRef:
    name: fireworksapp-tgz
    namespace: demo-system
EOF
```{{exec}}

Let's check the status of the `FormTemplate` `fireworksapp-tgz` resource:

```plain
kubectl get formtemplate fireworksapp-tgz --namespace demo-system -o yaml
```{{exec}}

The status returns the Custom Resource Definition (CRD) of the Composition. In Krateo, a CRD is the template we're going to expose as a Form in the Portal.
