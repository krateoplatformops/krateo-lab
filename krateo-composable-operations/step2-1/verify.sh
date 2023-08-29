#!/bin/bash

kubectl wait definition sample-archive --for condition=Ready=True --namespace krateo-system
