#!/bin/bash

kubectl wait deployment core-provider --for condition=Available=True --timeout=60s --namespace krateo-system
