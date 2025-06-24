#!/bin/bash

# Wait for the restdefinition to be ready with an empty message
kubectl wait teamrepo.github.kog.krateo.io/test-teamrepo --for condition=Ready=True --namespace gh-system --timeout=600s

# Additional check to ensure the message is empty
while true; do
  MESSAGE=$(kubectl get teamrepo.github.kog.krateo.io/test-teamrepo -n gh-system -o jsonpath='{.status.conditions[?(@.type=="Ready")].message}')
  if [ -z "$MESSAGE" ]; then
    break
  else
    echo "Waiting for empty message... Current message: '$MESSAGE'"
    sleep 5
  fi
done