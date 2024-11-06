#!/bin/bash

while true; do
    # Wait for 20 seconds before checking again
    sleep 20

    # Load the YAML resource using kubectl get
    resource_yaml=$(kubectl get restdefinition gh-repo -n gh-system -o yaml)

    # Check if the krateo.io/external-create-pending annotation is present
    if grep -q ! grep -q 'krateo.io/external-create-succeeded' <<< "$resource_yaml"; then
        echo "Removing finalizers and deleting the resource."

        # Remove the finalizers using kubectl patch
        kubectl patch restdefinition gh-repo -n gh-system --type=json -p='[{"op":"remove","path":"/metadata/finalizers"}]'

        # Delete the resource
        kubectl delete restdefinition gh-repo -n gh-system

        # Apply the resource again

        cat <<EOF | kubectl apply -f -
kind: RestDefinition
apiVersion: swaggergen.krateo.io/v1alpha1
metadata:
  name: gh-repo
  namespace: gh-system
spec:
  oasPath: https://raw.githubusercontent.com/krateoplatformops/github-oas3/1c1a6332378a931b5998b00742bcfbf136601b18/repo.yaml
  resourceGroup: gen.github.com
  resource: 
    kind: Repo
    identifiers:
      - id 
      - name
      - html_url
    verbsDescription:
    - action: create
      method: POST
      path: /orgs/{org}/repos
    - action: delete
      method: DELETE
      path: /repos/{org}/{name}
    - action: get
      method: GET
      path: /repos/{org}/{name}
EOF
    else
        echo "The krateo.io/external-create-pending annotation is not present, not deleting the resource."
    fi
done