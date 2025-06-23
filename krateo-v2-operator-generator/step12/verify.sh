#!/bin/bash

# Wait for the restdefinition to be ready with an empty message
kubectl wait restdefinition gh-teamrepo --for condition=Ready=True --namespace gh-system --timeout=600s

# Additional check to ensure the message is empty
while true; do
  MESSAGE=$(kubectl get restdefinition gh-teamrepo -n gh-system -o jsonpath='{.status.conditions[?(@.type=="Ready")].message}')
  if [ -z "$MESSAGE" ]; then
    echo "RestDefinition gh-teamrepo is ready with empty message"
    break
  else
    echo "Waiting for empty message... Current message: '$MESSAGE'"
    sleep 5
  fi
done