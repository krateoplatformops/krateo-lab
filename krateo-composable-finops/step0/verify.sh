#!/bin/bash

kubectl rollout status --watch --timeout=600s statefulset/vcluster -n vcluster
