#!/bin/bash

kubectl wait definition sample-repo --for condition=Ready=True --namespace krateo-system
