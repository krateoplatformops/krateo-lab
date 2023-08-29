#!/bin/bash

kubectl wait deployment core-provider --for condition=Available=True --namespace krateo-system
