#!/bin/bash

kubectl wait definition sample --for condition=Ready=True --timeout=300s --namespace krateo-system
