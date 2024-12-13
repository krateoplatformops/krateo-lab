#!/bin/bash

kubectl wait deployment finops-operator-focus-controller-manager --for condition=Available=True --timeout=300s --namespace finops
