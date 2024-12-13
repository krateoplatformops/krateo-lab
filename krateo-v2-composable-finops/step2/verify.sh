#!/bin/bash

kubectl wait deployment finops-operator-scraper-controller-manager --for condition=Available=True --timeout=300s --namespace finops
