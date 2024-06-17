#!/bin/bash

kubectl wait deployment finops-operator-exporter-controller-manager --for condition=Available=True --timeout=300s --namespace finops
