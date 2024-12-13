#!/bin/bash

kubectl wait pod crate-data-hot-cratedb-cluster-0 -n finops --for condition=Ready=True --timeout=300s
