#!/bin/bash

kubectl wait deployment operator-scraper-controller-manager --for condition=Available=True --timeout=300s --namespace finops
