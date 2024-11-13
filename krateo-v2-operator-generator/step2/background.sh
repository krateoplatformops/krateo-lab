#!/bin/bash

while true; do
    # Wait for 20 seconds before checking again
    sleep 20

    # Load the YAML resource using kubectl get
    resource_yaml=$(kubectl get restdefinition gh-repo -n gh-system -o yaml 2> /dev/null)

    # Check if the krateo.io/external-create-pending annotation is present
    if [ $? == 0 ] && ! grep -q 'krateo.io/external-create-succeeded' <<< "$resource_yaml" &&  grep -q 'krateo.io/external-create-pending'; then
        kubectl patch restdefinition gh-repo -n gh-system --type=json -p='[{"op":"remove","path":"/metadata/annotations/krateo.io~1external-create-pending"}]' 2>/dev/null
    else
        echo "The krateo.io/external-create-pending annotation is not present, not deleting the resource."
    fi
done