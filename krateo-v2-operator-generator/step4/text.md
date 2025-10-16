# Creating a Repository

## Prerequisites
Before creating the `Repo` custom resource, you need to create a `RepoConfiguration` custom resource and a Kubernetes secret to store your GitHub token.

These are used to authenticate requests to the GitHub API. The `bearer` section of the spec of `RepoConfiguration` contains a reference to the token that is used to authenticate the requests. The token is stored in a Kubernetes secret.

So first, create a Kubernetes secret with your GitHub token: 
(generate a personal access token with the necessary permissions from your GitHub account settings)

1. Open the Killercoda IDE and navigate to the following file:
```
/root/filesystem/github-repo-creds.yaml
```
2. Modify the file to include your GitHub token.
3. Apply the credentials manifest:
```bash
kubectl apply -f /root/filesystem/github-repo-creds.yaml
```{{exec}}

## Step 1: Install the Configuration for Repo
Install the BearerAuth custom resource to enable GitHub authentication:
```bash
cat <<EOF | kubectl apply -f -
apiVersion: github.ogen.krateo.io/v1alpha1
kind: RepoConfiguration
metadata:
  name: my-repo-config
  namespace: gh-system
spec:
  authentication:
    bearer:
      # Reference to a secret containing the bearer token
      tokenRef:
        name: gh-token        # Name of the secret
        namespace: gh-system    # Namespace where the secret exists
        key: token            # Key within the secret that contains the token

EOF
```{{exec}}

## Step 2: Create the Repo CR

Create a custom resource for the `repo` object. This is used to create, update, and delete teamrepos in the GitHub API. The `repo` object contains a reference to the `RepoConfiguration` object that is used to authenticate requests:
```bash
cat <<EOF | kubectl apply -f -
apiVersion: github.ogen.krateo.io/v1alpha1
kind: Repo
metadata:
  name: gh-repo-1
  namespace: gh-system
spec:
  configurationRef:
    name: my-repo-config
    namespace: gh-system
  org: krateoplatformops-test
  name: krateo-test-repo
  description: A short description of the repository set by Krateo
  visibility: public
  has_issues: true
EOF
```{{exec}}

You will expect that the controller creates a repository in your GitHub account with the name `krateo-test-repo` under the organization `krateoplatformops-test`. You can check the status of the repository by running:

```bash
kubectl describe repo.github.ogen.krateo.io/gh-repo-1 -n gh-system
```{{exec}}

You should see a successful creation event, which indicates that the repository was created successfully.

``` text
Events:
  Type     Reason                         Age                  From  Message
  ----     ------                         ----                 ----  -------
  Normal   CreatedExternalResource        6m30s                      Successfully requested creation of external resource
```

Any edits to the `Repo` custom resource will trigger the controller to update the corresponding repository in GitHub.

## Step 3: Wait for for the CR to become Ready
Wait for the controller to process the `Repo` resource. You can check the status of the
controller by running:

```bash
kubectl wait repoes gh-repo-1 --for condition=Ready=True --namespace gh-system
```{{exec}}