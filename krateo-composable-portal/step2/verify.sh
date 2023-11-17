#!/bin/bash

kubectl wait deployment krateo-gateway --for condition=Available=True --namespace krateo-system
