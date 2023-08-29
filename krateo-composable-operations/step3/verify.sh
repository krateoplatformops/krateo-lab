#!/bin/bash

kubectl wait postgresql sample --for condition=Ready=True --namespace krateo-system
