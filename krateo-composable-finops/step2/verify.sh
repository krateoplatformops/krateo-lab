#!/bin/bash

kubectl wait deployment scraper-finops-operator-scraper-controller-manager --for condition=Available=True --timeout=300s --namespace finops
