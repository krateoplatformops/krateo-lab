# Create the TeamRepo CR
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

Create a custom resource for the `bearerauth` object. (You can skip the secret and bearerAuth creation if you've completed the `repo` tutorial in the previous section.) This is used to authenticate requests to the GitHub API. The `bearerauth` object contains a reference to the token used for authentication, which is stored in a Kubernetes secret.

First, create a secret with your GitHub token (generate a personal access token with the necessary permissions from your GitHub account settings): (note that you can probably skip this step if you have already created the secret in a previous steps)

```bash
kubectl create secret generic gh-token --from-literal=token=<your-token> -n gh-system 
```{{exec}}

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

## Step 2: Create the TeamRepo CR

Create a custom resource for the `teamrepo` object. This is used to create, update, and delete teamrepos in the GitHub API. The `teamrepo` object contains a reference to the `bearerauth` object used for authentication:

```bash
cat <<EOF | kubectl apply -f -
apiVersion: github.kog.krateo.io/v1alpha1
kind: TeamRepo
metadata:
  name: test-teamrepo
  namespace: gh-system
spec:
  authenticationRefs:
    bearerAuthRef: gh-bearer
  org: krateoplatformops-test
  owner: krateoplatformops-test
  team_slug: prova
  repo: test-teamrepo
  permission: admin
EOF
```{{exec}}

The controller should add the GitHub team "prova" to the repository "test-teamrepo" in the organization "krateoplatformops-test" with "admin" permission. (Notes that the team "prova" must already exist in your GitHub organization, same for the repository "test-teamrepo")

Wait for the controller to process the `teamrepo` resource. You can check the status of the controller by running:

```bash
kubectl wait --for=condition=Ready=True --timeout=60s teamrepo.github.kog.krateo.io/test-teamrepo -n gh-system
```{{exec}}

Check the teamrepo creation status by running:

```bash
kubectl describe teamrepo.github.kog.krateo.io/test-teamrepo -n gh-system
```{{exec}}

You should see the teamrepo creation status and any errors that occurred during the process.

In this case, you should see that the teamrepo was created successfully with status `Ready`: `True`, but you should also notice that the `Message` field states "Resource is assumed to be up-to-date. Returned body is nil."

```text
...
Status:
  Conditions:
    Last Transition Time:  2025-06-18T14:13:03Z
    Message:               Resource is assumed to be up-to-date. Returned body is nil.
    Reason:                Available
    Status:                True
    Type:                  Ready
Events:
  Type    Reason                   Age   From  Message
  ----    ------                   ----  ----  -------
  Normal  CreatedExternalResource  86s         Successfully requested creation of external resource
```

This message indicates that the controller was able to create the teamrepo in GitHub, but the response body from the GitHub API is nil. This is expected behavior as described [here](https://docs.github.com/en/rest/teams/teams?apiVersion=2022-11-28#check-team-permissions-for-a-repository). According to the GitHub API documentation, the response body for this endpoint is empty when the request is successful but the accept header isn't set to `application/vnd.github.v3+json`. This is a known limitation of the GitHub API, and it's not possible to change the accept header for requests made by the `rest-dynamic-controller` directly.

To add the header to the request, we need to implement a web service that handles API calls to the GitHub API. The web service will be responsible for adding the header to the request and returning the response body, since the `rest-dynamic-controller` doesn't support adding headers to requests made to external APIs.