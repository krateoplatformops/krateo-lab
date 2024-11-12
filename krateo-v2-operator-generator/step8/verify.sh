#!/bin/bash

kubectl wait restdefinitions gh-collaborators --for condition=Ready=True --namespace gh-system --timeout=300s