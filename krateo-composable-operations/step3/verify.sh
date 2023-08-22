#!/bin/bash

kubectl wait postgresql sample --for condition=Ready=True --timeout=300s --namespace krateo-system
