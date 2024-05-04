#!/bin/bash

kubectl wait compositiondefinition sample-repo --for condition=Ready=True --namespace krateo-system
