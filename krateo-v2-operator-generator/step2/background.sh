#!/bin/bash

while true; do
    # Wait for 20 seconds before checking again
    sleep 20

    echo "Checking if the resource 'gh-repo' exists..."

    # Load the YAML resource using kubectl get, suppressing errors if not found
    resource_yaml=$(kubectl get restdefinition gh-repo -n gh-system -o yaml 2>/dev/null)

    # Check if the resource was found and handle potential errors
    if [ $? -eq 0 ]; then
        echo "Resource found. Checking for annotations..."

        # Check if the annotation 'krateo.io/external-create-succeeded' is not present
        if ! grep -q 'krateo.io/external-create-succeeded' <<< "$resource_yaml"; then
            echo "Removing finalizers and deleting the resource."

            # Check if finalizers are present
            if grep -q 'finalizers' <<< "$resource_yaml"; then
                echo "Finalizers are present, removing them."

                # Remove finalizers using kubectl patch and suppress errors
                kubectl patch restdefinition gh-repo -n gh-system --type=json -p='[{"op":"remove","path":"/metadata/finalizers"}]' 2>/dev/null || {
                    echo "Failed to remove finalizers, continuing..."
                }
            fi

            # Delete the resource, suppressing errors
            kubectl delete restdefinition gh-repo -n gh-system 2>/dev/null || {
                echo "Failed to delete the resource, continuing..."
            }

            # Apply the resource again
            echo "Re-applying the resource definition..."
            cat <<EOF | kubectl apply -f - 2>/dev/null || {
                echo "Failed to apply the resource definition, continuing..."
            }
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
            echo "The annotation 'krateo.io/external-create-succeeded' is present, not deleting the resource."
        fi
    else
        echo "Resource 'gh-repo' not found, skipping deletion and re-application."
    fi
done
