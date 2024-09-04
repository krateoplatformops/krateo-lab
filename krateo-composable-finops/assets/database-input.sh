#!/bin/bash

echo "Input your Databricks's hostname"
read hostname

echo "Input your access token"
read token

echo "Input your compute cluster name"
read clusterName

echo "Input your full notebook path"
read notebookPath

tokenbase=$(echo -n "$token" | base64)

printf "apiVersion: v1
kind: Secret
metadata:
  name: databricks-token
  namespace: finops
data:
  bearer-token: %s" $tokenbase > token.yaml

printf "apiVersion: finops.krateo.io/v1
kind: DatabaseConfig
metadata:
  name: finops-tutorial-config
  namespace: finops
spec:
  host: %s
  token:
    name: databricks-token
    namespace: finops
  clusterName: %s
  notebookPath: %s" $hostname $clusterName $notebookPath > database.yaml
