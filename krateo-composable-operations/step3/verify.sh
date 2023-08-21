#!/bin/bash

kubectl wait dummychart sample --for condition=Ready=True --timeout=300s --namespace krateo-system
