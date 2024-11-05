#!/bin/bash

kubectl get deployment fireworksapps-v1-1-6-controller --namespace krateo-system --wait

kubectl wait compositiondefinition fireworksapp-1-1-5 --for condition=Ready=True --namespace krateo-system
