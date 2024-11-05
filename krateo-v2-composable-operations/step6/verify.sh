#!/bin/bash

kubectl wait deployment fireworksapps-v1-1-6-controller --namespace fireworksapp-system --for condition=Available=True

kubectl wait compositiondefinition fireworksapp-1-1-5 --for condition=Ready=True --namespace fireworksapp-system
