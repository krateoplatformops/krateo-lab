#!/bin/bash

kubectl wait deployment authn-service --for condition=Available=True --namespace krateo-system
