# Manage TeamRepo CR

## Verify the TeamRepo Status

We wait until the `RestDefinition` is ready and the message is empty, indicating that the controller has successfully updated the RestDefinition to use the web service for the `get` operation.

```bash
#!/bin/bash

# Wait for the restdefinition to be ready with an empty message
kubectl wait teamrepo.github.ogen.krateo.io/test-teamrepo --for condition=Ready=True --namespace gh-system --timeout=600s

# Additional check to ensure the message is empty
while true; do
  MESSAGE=$(kubectl get teamrepo.github.ogen.krateo.io/test-teamrepo -n gh-system -o jsonpath='{.status.conditions[?(@.type=="Ready")].message}')
  if [ -z "$MESSAGE" ]; then
    break
  else
    echo "Waiting for empty message... Current message: '$MESSAGE'"
    sleep 5
  fi
done
```{{exec}}

## Check the TeamRepo Status

We expect the controller to update the RestDefinition and start using the web service to handle the `get` operation for teamrepos.
At this point, the `rest-dynamic-controller` should be able to handle the `get` operation for teamrepos using the web service. You can check the status of the TeamRepo resource by running:

```bash
kubectl describe teamrepo.github.ogen.krateo.io/test-teamrepo -n gh-system
```{{exec}}

You should see that the message field is now empty, which means the RestDefinition is ready and correctly observed by the controller.

## Update the TeamRepo Permission

To check if the remote resource changes along with the custom resource, you can run the following command to change the teamrepo's permission:

1. Open the Killercoda IDE and navigate to the following file:
```
/root/filesystem/cr/teamrepo-1.yaml
```
2. Modify the file to include your GitHub organization name and team slug. Also change the permission from `admin` to `pull`.
3. Apply the credentials manifest:
```bash
kubectl apply -f /root/filesystem/cr/teamrepo-1.yaml
```{{exec}}

After a few seconds, you should see that the teamrepo's permission is updated in GitHub (notest that GitHub Web map 'pull' permission to 'read'). Check the teamrepo status by running:

```bash
kubectl describe teamrepo.github.ogen.krateo.io/test-teamrepo -n gh-system
```{{exec}}

You should see that the permission is updated to `pull`, the status is set to `Ready`: `True`, and events indicate that the external resource was updated successfully:

```text
Events:
  Type     Reason                         Age                  From  Message
  ----     ------                         ----                 ----  -------
  Normal   UpdatedExternalResource        77s (x2 over 80s)             Successfully requested update of external resource
```

## Delete the Custom Resource

To delete the teamrepo, you can delete the `TeamRepo` custom resource:

```bash
kubectl delete teamrepo.github.ogen.krateo.io test-teamrepo -n gh-system
```{{exec}}

This will trigger the controller to delete the corresponding teamrepo in GitHub.

You should see an event for the TeamRepo resource indicating that the external resource was deleted successfully. Check the deletion status by running:

```bash
kubectl get events --sort-by='.lastTimestamp' -n gh-system | grep teamrepo/test-teamrepo
```{{exec}}

```text
Events:
  Type     Reason                         Age                  From  Message
  ----     ------                         ----                 ----  -------
  Normal   DeletedExternalResource      teamrepo/test-teamrepo        Successfully requested deletion of external resource
```

This indicates that the teamrepo was deleted successfully from GitHub. You can manually check the GitHub UI to confirm that the teamrepo is no longer present.