#!/bin/bash

kubectl wait compositiondefinition sample-oci --for condition=Ready=True --namespace krateo-system
