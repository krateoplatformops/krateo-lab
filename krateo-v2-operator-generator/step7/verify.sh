#!/bin/bash

kubectl wait po github-plugin --for condition=Ready=True --namespace krateo-system --timeout=300s
