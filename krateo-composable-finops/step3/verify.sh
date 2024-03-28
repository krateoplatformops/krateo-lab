#!/bin/bash

kubectl wait deployment operator-focus-controller-manager --for condition=Available=True --timeout=300s --namespace operator-focus-system
