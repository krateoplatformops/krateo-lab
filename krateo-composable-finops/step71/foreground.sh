#!/bin/bash

echo "Input your Databricks's hostname"
read hostname

echo "Input your access token"
read token

echo "Input your compute cluster name"
read clusterName

echo "Input your full notebook path"
read notebookPath

printf "apiVersion: finops.krateo.io/v1
kind: DatabaseConfig
metadata:
  name: finops-tutorial-config
  namespace: default
spec:
  host: %s
  token: %s
  clusterName: %s
  notebookPath: %s" $hostname $token $clusterName $notebookPath > database.yaml


