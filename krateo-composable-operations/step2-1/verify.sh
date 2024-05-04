#!/bin/bash

kubectl wait compositiondefinition sample-archive --for condition=Ready=True --namespace krateo-system
