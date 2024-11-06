#!/bin/bash

kubectl wait restdefinitions gh-repo --for condition=Ready=True --namespace gh-system --timeout=300s