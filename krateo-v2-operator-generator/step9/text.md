## Apply the Custom Resource

If you've set up the necessary authentication in the previous step, you can skip the prerequisites.

## Prerequisites

Before creating the repositories, you'll need to configure GitHub authentication by setting up the appropriate credentials in the cluster.

### Step 1: Configure GitHub Token

1. Open the Killercoda IDE and navigate to the following file:
```
/root/filesystem/github-repo-creds.yaml
```
2. Modify the file to include your GitHub token.
3. Apply the credentials manifest:
```bash
kubectl apply -f /root/filesystem/github-repo-creds.yaml
```{{exec}}

### Step 2: Install the BearerAuth CR
Install the BearerAuth custom resource to enable GitHub authentication:
```bash
kubectl apply -f /root/filesystem/gh-auth.yaml
```{{exec}}

## Edit the Custom Resource Specifications
Open the following file in the Killercoda IDE:
```
/root/filesystem/collaborators-cr.yaml
```
In this file, update the following fields according to your needs:
- `spec.owner`
- `spec.repo`
- `spec.username`
- `spec.permission`

**## Apply the Custom Resource**
Once you've updated the Custom Resource specification, apply it:
```bash
kubectl apply -f /root/filesystem/collaborators-cr.yaml
```{{exec}}

## Step 5: Verify the Installation
1. Wait for the Collaborators CR to reach the `Ready=True` condition:
 ```bash
 kubectl wait collaborators.gen.github.com/gh-collaborator --for condition=Ready=True --namespace gh-system
 ```{{exec}}
2. Check the status of the Collaborators CR:
 ```bash
 kubectl get collaborators.gen.github.com/gh-collaborator --namespace gh-system -o yaml
 ```{{exec}}

At this point, if the specified user was not part of the repository, an invitation to be added as a collaborator has been sent.