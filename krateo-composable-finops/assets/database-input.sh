#!/bin/bash

tokenbase=$(kubectl get secret user-system-cratedb-cluster -n finops -o json | jq -r '.data.password')

printf "apiVersion: v1
kind: Secret
metadata:
  name: cratedb-token
  namespace: finops
data:
  token: %s" $tokenbase > token.yaml

printf "apiVersion: finops.krateo.io/v1
kind: DatabaseConfig
metadata:
  name: finops-tutorial-config
  namespace: finops
spec:
  username: system
  passwordSecretRef:
    name: cratedb-token
    namespace: finops
    key: token" > database.yaml
