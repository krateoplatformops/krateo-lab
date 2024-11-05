#!/bin/bash

kubectl wait fireworksapp fireworksapp-composition-2 --for condition=Ready=True --namespace fireworksapp-system
kubectl wait fireworksapp fireworksapp-composition-1 --for condition=Ready=True --namespace fireworksapp-system