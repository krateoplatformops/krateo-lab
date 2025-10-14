# Installing a Krateo Github Scaffolding Blueprint Composition

As described in the [chart's README](https://github.com/krateoplatformops-blueprints/github-scaffolding/blob/main/README.md), you need to install the toolchain in the `krateo-system` namespace.

## Step 1: Install Required Components

First, add and update the necessary Helm repositories, then install the required providers:

```bash
# Add and update Krateo repository
helm repo add marketplace https://marketplace.krateo.io
helm repo update marketplace
helm install github-provider-kog-repo marketplace/github-provider-kog-repo --namespace krateo-system --create-namespace --wait --version 1.0.0
helm install git-provider krateo/git-provider --namespace krateo-system --create-namespace --wait --version 0.10.1
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update argo
helm install argocd argo/argo-cd --namespace krateo-system --create-namespace --wait --version 8.0.17
```{{exec}}

In this guide, we skip the argo-cd configuration steps, as it does not properly works in the Killercoda environment.

## Prerequisites
Before creating the Composition, we need to configure GitHub authentication. This requires setting up proper credentials in the cluster.

### Generate a token for GitHub user

In order to generate a token, follow this instructions: https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens#creating-a-personal-access-token-classic

Give the following permissions: delete:packages, delete_repo, repo, workflow, write:packages

### Configure GitHub Token
1. Open the Killercoda IDE and navigate to the file:
   ```
   /root/filesystem/github-repo-creds.yaml
   ```
2. Modify the file to include your GitHub token.

3. Apply the credentials manifest:
   ```bash
   kubectl apply -f /root/filesystem/github-repo-creds.yaml
   ```{{exec}}

### Wait for Github Provider to be Ready

```bash
kubectl wait restdefinitions.ogen.krateo.io github-provider-kog-repo --for condition=Ready=True --namespace krateo-system --timeout=300s
```{{exec}}


### Create a RepoConfiguration Custom Resource

Create a RepoConfiguration Custom Resource to make the GitHub Provider able to authenticate with the GitHub API using the previously created token.

```bash
cat <<EOF | kubectl apply -f -
apiVersion: github.ogen.krateo.io/v1alpha1
kind: RepoConfiguration
metadata:
  name: repo-config
  namespace: demo-system
spec:
  authentication:
    bearer:
      tokenRef:
        name: github-repo-creds
        namespace: krateo-system
        key: token
EOF
```{{exec}}

## Configure the Composition

Now that GitHub authentication is configured, you can create an instance of the composition.

Before proceeding, update the references to the GitHub organization where the repository will be created:

1. Open the Killercoda IDE and navigate to the following file:
   ```
   /root/filesystem/githubscaffolding-composition-values.yaml
   ```
2. Modify the `spec.toRepo.org` field to include your GitHub organization name.
3. Apply the updated manifest:
   ```bash
   kubectl apply -f /root/filesystem/githubscaffolding-composition-values.yaml
   ```{{exec}}


## Verify the Installation

1. Wait for the Composition to be ready:
   ```bash
   kubectl wait githubscaffolding gh-scaffolding-composition-1 --for condition=Ready=True \
     --timeout=300s --namespace ghscaffolding-system
   ```{{exec}}

2. Check the Composition's status:
   ```bash
   kubectl get githubscaffolding gh-scaffolding-composition-1 --namespace ghscaffolding-system
   ```{{exec}}

## Install another Composition

To install a second composition, repeat the process from Step 2 using the file `githubscaffolding-composition-values-2.yaml`:

```bash
kubectl apply -f /root/filesystem/githubscaffolding-composition-values-2.yaml
```{{exec}}

## Verify the Installation

1. Wait for the Composition to be ready:
   ```bash
   kubectl wait githubscaffolding gh-scaffolding-composition-2 --for condition=Ready=True \
     --timeout=300s --namespace ghscaffolding-system
   ```{{exec}}

2. Check the Composition's status:
   ```bash
   kubectl get githubscaffolding gh-scaffolding-composition-2 --namespace ghscaffolding-system
   ```{{exec}}

This will display the current status of your Github Scaffolding Blueprint Composition. Verify that all components have been properly deployed and are in a ready state.