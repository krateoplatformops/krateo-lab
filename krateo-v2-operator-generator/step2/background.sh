#!/bin/bash

while true; do
    # Wait for 10 seconds before checking again
    sleep 10

    # Load the YAML resource using kubectl get
    resource_yaml=$(kubectl get restdefinition gh-repo -n gh-system -o yaml)

    # Check if the krateo.io/external-create-pending annotation is present
    if grep -q 'krateo.io/external-create-pending' <<< "$resource_yaml" && ! grep -q 'krateo.io/external-create-succeeded' <<< "$resource_yaml"; then
        echo "Removing the krateo.io/external-create-pending annotation and deleting the resource."

        # Remove the krateo.io/external-create-pending annotation using kubectl patch
        kubectl patch restdefinition gh-repo -n gh-system --type=json -p='[{"op":"remove","path":"/metadata/annotations/krateo.io~1external-create-pending"}]'

        # Delete the resource
        kubectl delete restdefinition gh-repo -n gh-system
    else
        echo "The krateo.io/external-create-pending annotation is not present, not deleting the resource."
    fi
done