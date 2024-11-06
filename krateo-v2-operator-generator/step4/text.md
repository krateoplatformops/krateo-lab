# Creating a Repository

## Prerequisites
Before creating the Repoes, configure GitHub authentication by setting up the appropriate credentials in the cluster.

## Step 1: Configure GitHub Token
1. Open the Killercoda IDE and navigate to the following file:
```
/root/filesystem/github-repo-creds.yaml
```
2. Modify the file to include your GitHub token.
3. Apply the credentials manifest:
```bash
kubectl apply -f /root/filesystem/github-repo-creds.yaml
```{{exec}}

## Step 2: Install the BearerAuth CR
Install the BearerAuth custom resource to enable GitHub authentication:
```bash
kubectl apply -f /root/filesystem/gh-auth.yaml
```{{exec}}

## Step 3: Edit the Repository Specification
Now that GitHub authentication is configured, set the specification for the GitHub Repository you want to manage. Open the Killercoda IDE and navigate to the following file:

```
/root/filesystem/repo-cr.yaml
```

In this file, update the `"org"` field with the appropriate GitHub organization or your GitHub username if using a personal account.

## Step 4: Install the Repository Specification
Apply the repository specification to create the GitHub repository resource:

```bash
kubectl apply -f /root/filesystem/repo-cr.yaml
```{{exec}}

## Step 5: Verify the Installation

1. Wait for the Composition to reach the `Ready=True` condition:
   ```bash
   kubectl wait repoes gh-repo1 --for condition=Ready=True --namespace gh-system --timeout=300s 
   ```{{exec}}

2. Check the status of the Composition:
   ```bash
   kubectl get repoes gh-repo1 --namespace gh-system -o yaml
   ```{{exec}}

At this point, a public repository called **"test-generatore"** should be created in the organization specified in Step 3. You see it visiting the url specified in the "html_url" field in the status of the CR.