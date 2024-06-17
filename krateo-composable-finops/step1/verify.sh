#!/bin/bash

kubectl wait deployment exporter-finops-operator-exporter-controller-manager --for condition=Available=True --timeout=300s --namespace finops
