#!/bin/bash

kubectl wait deployment fireworksapps-v1-1-14-controller --namespace fireworksapp-system --for condition=Available=True

kubectl wait compositiondefinition fireworksapp-1-1-13 --for condition=Ready=True --namespace fireworksapp-system
