#!/bin/bash

kubectl wait repoes gh-repo1 --for condition=Ready=True --namespace gh-system