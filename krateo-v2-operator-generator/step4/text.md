# Creating a Repository

## Prerequisites
Create a custom resource for the `bearerauth` object. This is used to authenticate requests to the GitHub API. The `bearerauth` object contains a reference to the token that is used to authenticate the requests. The token is stored in a Kubernetes secret.

So first, create a secret with your GitHub token (generate a personal access token with the necessary permissions from your GitHub account settings), then:

1. Open the Killercoda IDE and navigate to the following file:
```
/root/filesystem/github-repo-creds.yaml
```
2. Modify the file to include your GitHub token.
3. Apply the credentials manifest:
```bash
kubectl apply -f /root/filesystem/github-repo-creds.yaml
```{{exec}}

## Step 1: Install the BearerAuth CR
Install the BearerAuth custom resource to enable GitHub authentication:
```bash
cat <<EOF | kubectl apply -f -
apiVersion: github.kog.krateo.io/v1alpha1
kind: BearerAuth
metadata:
  name: gh-bearer
  namespace: gh-system
spec:
  tokenRef:
    key: token
    name: gh-token
    namespace: gh-system
EOF
```{{exec}}

## Step 2: Create the Repo CR

Create a custom resource for the `Repo` object. This is used to create, update, and delete repositories in the GitHub API. The `Repo` object contains the reference to the `bearerauth` object that is used to authenticate the requests.

```bash
cat <<EOF | kubectl apply -f -
apiVersion: github.kog.krateo.io/v1alpha1
kind: Repo
metadata:
  name: gh-repo-1
  namespace: gh-system
spec:
  authenticationRefs:
    bearerAuthRef: gh-bearer 
  org: krateoplatformops-test
  name: krateo-test-repo
  description: A short description of the repository set by Krateo
  visibility: public
  has_issues: true
EOF
```{{exec}}

You will expect that the controller creates a repository in your GitHub account with the name `krateo-test-repo` under the organization `krateoplatformops-test`. You can check the status of the repository by running:

```bash
kubectl describe repo.github.kog.krateo.io/gh-repo-1 -n gh-system
```{{exec}}

You should see a successful creation event, which indicates that the repository was created successfully.

``` text
Events:
  Type     Reason                         Age                  From  Message
  ----     ------                         ----                 ----  -------
  Normal   CreatedExternalResource        6m30s                      Successfully requested creation of external resource
```

Any edits to the `Repo` custom resource will trigger the controller to update the corresponding repository in GitHub.