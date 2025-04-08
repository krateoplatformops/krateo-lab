#!/bin/bash

kubectl wait deployment fireworksapps-v1-1-14-controller --namespace fireworksapp-system --for condition=Available=True

kubectl wait compositiondefinition fireworksapp-cd --for condition=Ready=True --namespace fireworksapp-system
