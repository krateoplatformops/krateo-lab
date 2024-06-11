#!/bin/bash

kubectl wait compositiondefinition fireworksapp-tgz --for condition=Ready=True --namespace krateo-system
