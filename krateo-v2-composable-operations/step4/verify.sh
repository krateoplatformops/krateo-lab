#!/bin/bash

kubectl wait fireworksapp fireworksapp-tgz --for condition=Ready=True --namespace krateo-system
