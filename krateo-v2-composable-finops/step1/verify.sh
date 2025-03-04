#!/bin/bash

kubectl wait krateoplatformops krateo --for condition=Ready=True --namespace krateo-system --timeout=660s
