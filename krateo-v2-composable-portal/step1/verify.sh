#!/bin/bash

kubectl wait krateoplatformops krateo --for condition=Ready=True --timeout=300s --namespace krateo-system
