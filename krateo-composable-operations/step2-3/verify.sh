#!/bin/bash

kubectl wait definition sample-oci --for condition=Ready=True --timeout=300s --namespace krateo-system
