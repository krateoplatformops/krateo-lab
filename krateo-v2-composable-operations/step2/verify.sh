#!/bin/bash

kubectl wait compositiondefinition github-scaffolding --for condition=Ready=True --namespace ghscaffolding-system
