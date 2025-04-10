#!/bin/bash

kubectl scale --replicas=0 deployment/authn -n krateo-system
kubectl scale --replicas=0 deployment/eventrouter -n krateo-system
kubectl scale --replicas=0 deployment/eventsse -n krateo-system
kubectl scale --replicas=0 deployment/snowplow -n krateo-system
kubectl scale --replicas=0 statefulset/eventsse-etcd -n krateo-system