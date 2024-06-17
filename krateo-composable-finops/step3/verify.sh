#!/bin/bash

kubectl wait deployment focus-finops-operator-focus-controller-manager --for condition=Available=True --timeout=300s --namespace finops
