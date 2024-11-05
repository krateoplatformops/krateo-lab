#!/bin/bash


# Install the Installer CRD

kubectl apply -f https://raw.githubusercontent.com/krateoplatformops/installer-chart/refs/heads/main/chart/crds/krateo.io_krateoplatformops.yaml

# Deploy Installer

kubectl create namespace krateo-system

# Apply Installer Configuration Manifest
cat <<EOF | kubectl apply -f -
# installer.yaml
apiVersion: v1
data:
  INSTALLER_DEBUG: "true"
  INSTALLER_NAMESPACE: krateo-system
kind: ConfigMap
metadata:
  labels:
    app.kubernetes.io/instance: installer
    app.kubernetes.io/name: installer
  name: installer
  namespace: krateo-system
---
apiVersion: v1
automountServiceAccountToken: true
kind: ServiceAccount
metadata:
  labels:
    app.kubernetes.io/instance: installer
    app.kubernetes.io/name: installer
  name: installer
  namespace: krateo-system
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  labels:
    app.kubernetes.io/instance: installer
    app.kubernetes.io/name: installer
  name: installer
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: installer
subjects:
- kind: ServiceAccount
  name: installer
  namespace: krateo-system
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  labels:
    app.kubernetes.io/instance: installer
    app.kubernetes.io/name: installer
  name: installer
rules:
- apiGroups:
  - "*"
  resources:
  - "*"
  verbs:
  - '*'
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: installer
  namespace: krateo-system
spec:
  progressDeadlineSeconds: 600
  replicas: 1
  revisionHistoryLimit: 10
  selector:
    matchLabels:
      app.kubernetes.io/instance: installer
      app.kubernetes.io/name: installer
  strategy:
    rollingUpdate:
      maxSurge: 25%
      maxUnavailable: 25%
    type: RollingUpdate
  template:
    metadata:
      labels:
        app.kubernetes.io/instance: installer
        app.kubernetes.io/name: installer
        app.kubernetes.io/version: 0.5.7
    spec:
      containers:
      - envFrom:
        - configMapRef:
            name: installer
        image: ghcr.io/krateoplatformops/installer:0.5.7
        imagePullPolicy: IfNotPresent
        name: installer
        resources: {}
        securityContext: {}
        terminationMessagePath: /dev/termination-log
        terminationMessagePolicy: File
      dnsPolicy: ClusterFirst
      restartPolicy: Always
      schedulerName: default-scheduler
      securityContext: {}
      serviceAccount: installer
      serviceAccountName: installer
      terminationGracePeriodSeconds: 30
EOF

# Wait for the installer to be ready

kubectl wait --for=condition=available --timeout=600s deployment/installer -n krateo-system

# Apply Krateo Installer Manifest
cat <<EOF | kubectl apply -f -
# krateo-installer.yaml
apiVersion: krateo.io/v1alpha1
kind: KrateoPlatformOps
metadata:
  name: krateo
  namespace: krateo-system
spec:
  deletionPolicy: Delete
  steps:
  - id: install-authn
    type: chart
    with:
      name: authn
      repository: https://charts.krateo.io
      set:
      - name: image.repository
        value: ghcr.io/krateoplatformops/authn
      - name: image.pullPolicy
        value: IfNotPresent
      - name: service.type
        value: NodePort
      - name: service.nodePort
        value: "30082"
      - name: env.AUTHN_KUBECONFIG_SERVER_URL
        value: https://127.0.0.1:6443
      version: 0.17.0
      wait: true
      waitTimeout: 5m
  - id: extract-authn-nodeport-port
    type: var
    with:
      name: AUTHN_PORT
      valueFrom:
        apiVersion: v1
        kind: Service
        metadata:
          name: authn
        selector: .spec.ports[0].nodePort
  - id: install-bff
    type: chart
    with:
      name: bff
      repository: https://charts.krateo.io
      set:
      - name: image.repository
        value: ghcr.io/krateoplatformops/bff
      - name: image.pullPolicy
        value: IfNotPresent
      - name: service.type
        value: NodePort
      - name: service.nodePort
        value: "30081"
      version: 0.7.0
      wait: true
      waitTimeout: 5m
  # Additional installation steps omitted for brevity...
EOF
# Wait for the Krateo Platform to be ready

kubectl wait krateoplatformops krateo --for condition=Ready=True --timeout=600s --namespace krateo-system
