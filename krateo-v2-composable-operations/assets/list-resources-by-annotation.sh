#!/bin/bash

# Get the list of resources that support the 'list' verb
IFS=$'\n'
resources=($(kubectl api-resources --verbs=list -o name))

# Reset IFS to default value
unset IFS

# Iterate over each resource
for resource in "${resources[@]}"; do
    # Inform which resource is being processed
   # echo "Processing $resource:"

    # Execute the command for each resource and display its output
    kubectl get "$resource" -n krateo-system -o jsonpath='{range .items[?(@.metadata.annotations.meta\.helm\.sh/release-name=="fireworksapp")]}{.kind}{" "}{.metadata.name}{"\n"}{end}'
done
