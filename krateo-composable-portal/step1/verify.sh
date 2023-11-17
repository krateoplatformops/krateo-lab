#!/bin/bash

kubectl wait deployment krateo-bff --for condition=Available=True --namespace krateo-system
