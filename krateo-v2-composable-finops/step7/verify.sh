#!/bin/bash

kubectl wait deployment -n finops finops-database-handler --for condition=Available=True --timeout=300s

