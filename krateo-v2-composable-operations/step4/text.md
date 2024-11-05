# Installing a Krateo Fireworks App Composition

## Prerequisites
Before creating the Composition, we need to configure GitHub authentication. This requires setting up proper credentials in the cluster.

## Step 1: Configure GitHub Token
1. Open the Killercoda IDE and navigate to the file:
   ```
   /root/filesystem/github-repo-creds.yaml
   ```
2. Modify the file to include your GitHub token.

3. Apply the credentials manifest:
   ```bash
   kubectl apply -f /root/filesystem/github-repo-creds.yaml
   ```{{exec}}

## Step 2: Create the Composition
Now that GitHub authentication is configured, we can create an instance of the composition:

```bash
kubectl apply -f /root/filesystem/fireworksapp-composition-values.yaml
```{{exec}}

## Step 3: Verify the Installation

1. Wait for the Composition to be ready:
   ```bash
   kubectl wait fireworksapp fireworksapp-composition-1 --for condition=Ready=True \
     --timeout=300s --namespace fireworksapp-system
   ```{{exec}}

2. Check the Composition's status:
   ```bash
   kubectl get fireworksapp fireworksapp-composition-1 --namespace fireworksapp-system
   ```{{exec}}

Let's repeat the process to install a second composition:

```bash
kubectl apply -f /root/filesystem/fireworksapp-composition-values-2.yaml
```{{exec}}

## Step 3: Verify the Installation

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