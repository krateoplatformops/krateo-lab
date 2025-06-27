# Installing a Krateo Fireworks App Composition

## Prerequisites
Before creating the Composition, we need to configure GitHub authentication. This requires setting up proper credentials in the cluster.


## Wait for the Github Provider to be ready

Wait for the Github Provider to be ready:

```bash
until kubectl get deployment github-provider-kog-repo-controller -n krateo-system &>/dev/null; do
  echo "Waiting for Repo controller deployment to be created..."
  sleep 5
done
kubectl wait deployments github-provider-kog-repo-controller --for condition=Available=True --namespace krateo-system --timeout=300s
```{{exec}}

## Configure GitHub Token
1. Open the Killercoda IDE and navigate to the file:
   ```
   /root/filesystem/github-repo-creds.yaml
   ```
2. Modify the file to include your GitHub token.

3. Apply the credentials manifest:
   ```bash
   kubectl apply -f /root/filesystem/github-repo-creds.yaml
   ```{{exec}}


## Create a BearerAuth Custom Resource

Create a BearerAuth Custom Resource to make the GitHub Provider able to authenticate with the GitHub API using the previously created token.

cat <<EOF | kubectl apply -f -
apiVersion: github.kog.krateo.io/v1alpha1
kind: BearerAuth
metadata:
  name: bearer-github-ref
  namespace: fireworksapp-system
spec:
  tokenRef:
    key: token
    name: github-repo-creds
    namespace: krateo-system
EOF

## Configure the Composition

Now that GitHub authentication is configured, you can create an instance of the composition.

Before proceeding, update the references to the GitHub organization where the repository will be created:

1. Open the Killercoda IDE and navigate to the following file:
   ```
   /root/filesystem/fireworksapp-composition-values.yaml
   ```
2. Modify the `spec.toRepo.org` field to include your GitHub organization name.
3. Apply the updated manifest:
   ```bash
   kubectl apply -f /root/filesystem/fireworksapp-composition-values.yaml
   ```{{exec}}


## Verify the Installation

1. Wait for the Composition to be ready:
   ```bash
   kubectl wait fireworksapp fireworksapp-composition-1 --for condition=Ready=True \
     --timeout=300s --namespace fireworksapp-system
   ```{{exec}}

2. Check the Composition's status:
   ```bash
   kubectl get fireworksapp fireworksapp-composition-1 --namespace fireworksapp-system
   ```{{exec}}

## Install another Composition

To install a second composition, repeat the process from Step 2 using the file `fireworksapp-composition-values-2.yaml`:

```bash
kubectl apply -f /root/filesystem/fireworksapp-composition-values-2.yaml
```{{exec}}

## Verify the Installation

1. Wait for the Composition to be ready:
   ```bash
   kubectl wait fireworksapp fireworksapp-composition-2 --for condition=Ready=True \
     --timeout=300s --namespace fireworksapp-system
   ```{{exec}}

2. Check the Composition's status:
   ```bash
   kubectl get fireworksapp fireworksapp-composition-2 --namespace fireworksapp-system
   ```{{exec}}

This will display the current status of your Fireworks App Composition. Verify that all components have been properly deployed and are in a ready state.