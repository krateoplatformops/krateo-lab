#!/bin/bash


# Install the Installer CRD

kubectl apply -f https://raw.githubusercontent.com/krateoplatformops/installer-chart/refs/heads/main/chart/crds/krateo.io_krateoplatformops.yaml

# Deploy Installer

kubectl create namespace krateo-system

kubectl apply -f assets/installer.yaml

# Wait for the installer to be ready

kubectl wait --for=condition=available --timeout=600s deployment/installer -n krateo-system

# Apply the Manifests

kubectl apply -f assets/krateo-installer.yaml

# Wait for the Krateo Platform to be ready

kubectl wait krateoplatformops krateo --for condition=Ready=True --timeout=600s --namespace krateo-system
