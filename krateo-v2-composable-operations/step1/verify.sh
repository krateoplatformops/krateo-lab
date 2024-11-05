#!/bin/bash

kubectl wait krateoplatformops krateo --for condition=Ready=True --timeout=600s --namespace krateo-system

