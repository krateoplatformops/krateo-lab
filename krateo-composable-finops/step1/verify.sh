#!/bin/bash

kubectl wait deployment operator-exporter-controller-manager --for condition=Available=True --timeout=300s --namespace operator-exporter-system
