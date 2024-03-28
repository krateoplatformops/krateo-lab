#!/bin/bash

kubectl wait deployment exporterscraperconfig-sample-deployment --for condition=Available=True --timeout=300s
