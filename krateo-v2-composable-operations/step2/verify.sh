#!/bin/bash

kubectl wait compositiondefinition fireworksapp-1-1-5 --for condition=Ready=True --namespace krateo-system
