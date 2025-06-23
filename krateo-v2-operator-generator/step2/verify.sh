#!/bin/bash

kubectl wait restdefinition gh-repo --for condition=Ready=True --namespace gh-system --timeout=600s
