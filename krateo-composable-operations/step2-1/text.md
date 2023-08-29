
Let's install the Bitnami Postgresql Helm Chart using our `Definition`. There are three possible ways to install it: via tgz archive, via oci artifact or via Helm repo. In this first example, we will pull directly the archive of the Helm chart

<br>

```plain
cat <<EOF | kubectl apply -f -
apiVersion: core.krateo.io/v1alpha1
kind: Definition
metadata:
  name: sample-archive
  namespace: krateo-system
spec:
  chart:
    url: https://github.com/krateoplatformops/postgresql-demo-chart/releases/download/12.8.3/postgresql-12.8.3.tgz
EOF
```{{exec}}

Let's wait for the Definition `sample-archive` to be Ready

```plain
kubectl wait definition sample-archive --for condition=Ready=True --timeout=300s --namespace krateo-system
```{{exec}}

Check the Definition `sample-archive` outputs, expecially for the `RESOURCE` field.

```plain
kubectl get definition sample-archive --namespace krateo-system
```{{exec}}

The `core-provider` has just generated a Custom Resource Definition leveraging the values.json.schema file from the Helm chart and started a specific Pod from the `composition-dynamic-controller` image which will watch for new Custom Resources related to the generated CRD.
