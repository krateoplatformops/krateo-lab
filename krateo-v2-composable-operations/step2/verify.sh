#!/bin/bash

kubectl wait compositiondefinition fireworksapp-cd --for condition=Ready=True --namespace fireworksapp-system
