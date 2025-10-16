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

## Step 1: Install the Configuration for TeamRepo

Before creating the `TeamRepo` custom resource, you need to create a `TeamRepoConfiguration` custom resource and a Kubernetes secret to store your GitHub token.

These are used to authenticate requests to the GitHub API. The `bearer` section of the spec of `TeamRepoConfiguration` contains a reference to the token that is used to authenticate the requests. The token is stored in a Kubernetes secret.

```bash
cat <<EOF | kubectl apply -f -
apiVersion: github.ogen.krateo.io/v1alpha1
kind: TeamRepoConfiguration
metadata:
  name: my-teamrepo-config
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

## Step 2: Create the TeamRepo CR

Create a custom resource for the `teamrepo` object. This is used to create, update, and delete teamrepos in the GitHub API. The `teamrepo` object contains a reference to the `TeamRepoConfiguration` object that is used to authenticate requests:

1. Open the Killercoda IDE and navigate to the following file:
```
/root/filesystem/cr/teamrepo-1.yaml
```
2. Modify the file to include your GitHub organization name and team slug.
3. Apply the credentials manifest:
```bash
kubectl apply -f /root/filesystem/cr/teamrepo-1.yaml
```{{exec}}

The controller should add the GitHub team "prova" to the repository "test-teamrepo" in the organization you have set with "admin" permission. (Notes that the team "prova" must already exist in your GitHub organization, same for the repository "test-teamrepo")

Check the teamrepo creation status by running:

```bash
kubectl describe teamrepo.github.ogen.krateo.io/test-teamrepo -n gh-system
```{{exec}}

You should see the teamrepo creation status and any errors that occurred during the process.

In this case, you should see that the teamrepo was not created successfully because of errors from the GitHub API. This is because the `rest-dynamic-controller` is not able to handle the response body from the GitHub API for this endpoint correctly.

```text
...
Status:
  Conditions:
    Last Transition Time:  2025-10-16T10:19:54Z
    Message:               
    Reason:                Creating
    Status:                False
    Type:                  Ready
    Last Transition Time:  2025-10-16T10:19:54Z
    Message:               cannot determine creation result - remove the krateo.io/external-create-pending annotation if it is safe to proceed
    Reason:                ReconcileError
    Status:                False
    Type:                  Synced
Events:
  Type     Reason                           Age   From                     Message
  ----     ------                           ----  ----                     -------
  Warning  CannotCreateExternalResource     46s   rest-dynamic-controller  unexpected status: 404: invalid status code: 404
```

This message indicates that the controller was able to create the teamrepo in GitHub, but the response body from the GitHub API is nil. This is expected behavior as described [here](https://docs.github.com/en/rest/teams/teams?apiVersion=2022-11-28#check-team-permissions-for-a-repository). According to the GitHub API documentation, the response body for this endpoint is empty when the request is successful but the accept header isn't set to `application/vnd.github.v3+json`. This is a known limitation of the GitHub API, and it's not possible to change the accept header for requests made by the `rest-dynamic-controller` directly.

To add the header to the request, we need to implement a web service that handles API calls to the GitHub API. The web service will be responsible for adding the header to the request and returning the response body, since the `rest-dynamic-controller` doesn't support adding headers to requests made to external APIs.

In addition to the header issue, the response body from the GitHub API for this endpoint is also not in a format that is compatible with the `rest-dynamic-controller`. The response body contains uses a legacy format for permission values and the controller won't be able to compare the fields in the response body with the fields in the custom resource. Therefore, the web service normalizes permission values (write → push, read → pull).

Moreover, the `owner` field in the response body is not on the same level as the other fields in the custom resource, which makes it impossible for the `rest-dynamic-controller` to compare the fields correctly. The web service will also flatten the response body to bring the `owner` field to the root level.

More information about the web service endpoint can be found [here](https://github.com/krateoplatformops/github-rest-dynamic-controller-plugin/blob/main/README.md#get-teamrepo-permission)

Note: with a recent update of `oasgen-provider` and `rest-dynamic-controller`, it is now possible to add custom headers to the requests made to the external API by using configuration resources (e.g., `TeamRepoConfiguration`). However, this feature is not sufficient in this case because the response body from the GitHub API is still not in a format that is compatible with the `rest-dynamic-controller`. Therefore, we still need to implement a web service to handle the response body.