#!/bin/bash

kubectl wait repoes gh-repo-1 --for condition=Ready=True --namespace gh-system