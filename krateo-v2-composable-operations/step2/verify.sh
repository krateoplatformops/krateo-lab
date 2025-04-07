#!/bin/bash

kubectl wait compositiondefinition fireworksapp-1-1-13 --for condition=Ready=True --namespace fireworksapp-system
