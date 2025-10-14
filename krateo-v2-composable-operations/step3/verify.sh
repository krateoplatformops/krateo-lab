#!/bin/bash

kubectl wait githubscaffolding gh-scaffolding-composition-2 --for condition=Ready=True --namespace ghscaffolding-system
kubectl wait githubscaffolding gh-scaffolding-composition-1 --for condition=Ready=True --namespace ghscaffolding-system