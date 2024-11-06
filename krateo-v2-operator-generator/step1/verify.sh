#!/bin/bash

kubectl wait deployments krateo-oasgen-provider --for condition=Available=True --namespace krateo-system --timeout=300s

