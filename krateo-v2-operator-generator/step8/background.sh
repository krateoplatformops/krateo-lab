#!/bin/bash

while true; do
    # Wait for 20 seconds before checking again
    sleep 20

    # Load the YAML resource using kubectl get
    resource_yaml=$(kubectl get restdefinition gh-collaborators -n gh-system -o yaml)

    # Check if the krateo.io/external-create-pending annotation is present
    if ! grep -q 'krateo.io/external-create-succeeded' <<< "$resource_yaml"; then
        echo "Removing finalizers and deleting the resource."

        # Remove the finalizers using kubectl patch
        kubectl patch restdefinition gh-collaborators -n gh-system --type=json -p='[{"op":"remove","path":"/metadata/finalizers"}]'

        # Delete the resource
        kubectl delete restdefinition gh-collaborators -n gh-system

        # Apply the resource again

        cat <<EOF | kubectl apply -f -
kind: RestDefinition
apiVersion: swaggergen.krateo.io/v1alpha1
metadata:
  name: gh-collaborators
  namespace: gh-system
spec:
  oasPath: https://raw.githubusercontent.com/krateoplatformops/github-oas3/refs/heads/main/collaborators.yaml
  resourceGroup: gen.github.com
  resource: 
    kind: Collaborators
    identifiers:
      - id 
      - permissions
      - html_url
    verbsDescription:
    - action: create
      method: PUT
      path: /repos/{owner}/{repo}/collaborators/{username}
    - action: delete
      method: DELETE
      path: /repos/{owner}/{repo}/collaborators/{username}
    - action: get
      method: GET
      path: /repository/{owner}/{repo}/collaborators/{username}/permission
    - action: update
      method: PUT
      path: /repos/{owner}/{repo}/collaborators/{username}
EOF
    else
        echo "The krateo.io/external-create-pending annotation is not present, not deleting the resource."
    fi
done