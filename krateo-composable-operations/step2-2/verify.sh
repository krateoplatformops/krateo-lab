#!/bin/bash

kubectl wait definition sample-oci --for condition=Ready=True --namespace krateo-system
