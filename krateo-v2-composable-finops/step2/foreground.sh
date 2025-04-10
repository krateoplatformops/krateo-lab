#!/bin/bash

kubectl scale --replicas=0 deployment/authn -n krateo-system
kubectl scale --replicas=0 deployment/backend -n krateo-system
kubectl scale --replicas=0 deployment/core-provider -n krateo-system
kubectl scale --replicas=0 deployment/core-provider-chart-inspector -n krateo-system
kubectl scale --replicas=0 deployment/eventrouter -n krateo-system
kubectl scale --replicas=0 deployment/eventsse -n krateo-system
kubectl scale --replicas=0 deployment/snowplow -n krateo-system
kubectl scale --replicas=0 deployment/krateo-frontend -n krateo-system
kubectl scale --replicas=0 deployment/oasgen-provider -n krateo-system
kubectl scale --replicas=0 deployment/patch-provider -n krateo-system
kubectl scale --replicas=0 deployment/resource-tree-handler -n krateo-system