# Massive composition install
Try to Install 25 compositions in the cluster and wait for `Ready:True` condition

```bash
kubectl apply -f /root/filesystem/stress-test-cdc.yaml
```{{exec}}

Let's see the status:

```bash
kubectl get compositions -n fireworksapp-system
```{{exec}}

Now, try to delete them:

```bash
kubectl delete -f /root/filesystem/stress-test-cdc.yaml
```{{exec}}

Let's see the status:

```bash
kubectl get compositions -n fireworksapp-system
```{{exec}}