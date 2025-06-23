#!/bin/bash

kubectl wait restdefinition gh-teamrepo --for condition=Ready=True --namespace gh-system --timeout=600s
