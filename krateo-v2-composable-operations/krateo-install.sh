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
  - id: extract-bff-nodeport-port
    type: var
    with:
      name: BFF_PORT
      valueFrom:
        apiVersion: v1
        kind: Service
        metadata:
          name: bff
        selector: .spec.ports[0].nodePort
  - id: install-backend-etcd
    type: chart
    with:
      name: etcd
      repository: https://charts.krateo.io
      set:
      - name: auth.rbac.create
        value: "false"
      - name: global.compatibility.openshift.adaptSecurityContext
        value: auto
      - name: global.imageRegistry
        value: ghcr.io
      - name: image.repository
        value: krateoplatformops/etcd
      - name: image.pullPolicy
        value: IfNotPresent
      - name: image.tag
        value: 3.5.15-debian-12-r3
      version: 10.2.9
      wait: true
      waitTimeout: 5m
  - id: install-backend
    type: chart
    with:
      name: backend
      repository: https://charts.krateo.io
      set:
      - name: image.repository
        value: ghcr.io/krateoplatformops/backend
      - name: image.pullPolicy
        value: IfNotPresent
      version: 0.13.0
      wait: true
      waitTimeout: 5m
  - id: install-eventrouter
    type: chart
    with:
      name: eventrouter
      repository: https://charts.krateo.io
      set:
      - name: image.repository
        value: ghcr.io/krateoplatformops/eventrouter
      - name: image.pullPolicy
        value: IfNotPresent
      version: 0.5.7
      wait: true
      waitTimeout: 5m
  - id: install-eventsse
    type: chart
    with:
      name: eventsse
      repository: https://charts.krateo.io
      set:
      - name: image.repository
        value: ghcr.io/krateoplatformops/eventsse
      - name: image.pullPolicy
        value: IfNotPresent
      - name: service.type
        value: NodePort
      - name: service.nodePort
        value: "30083"
      version: 0.4.3
      wait: true
      waitTimeout: 5m
  - id: extract-eventsse-nodeport-port
    type: var
    with:
      name: EVENTSSE_PORT
      valueFrom:
        apiVersion: v1
        kind: Service
        metadata:
          name: eventsse-external
        selector: .spec.ports[0].nodePort
  - id: extract-bff-internal-port
    type: var
    with:
      name: BFF_INTERNAL_PORT
      valueFrom:
        apiVersion: v1
        kind: Service
        metadata:
          name: bff
        selector: .spec.ports[0].port
  - id: install-core-provider
    type: chart
    with:
      name: core-provider
      repository: https://charts.krateo.io
      set:
      - name: image.repository
        value: ghcr.io/krateoplatformops/core-provider
      - name: image.pullPolicy
        value: IfNotPresent
      - name: env.URL_PLURALS
        value: http://bff.krateo-system.svc.cluster.local:$BFF_INTERNAL_PORT/api-info/names
      version: 0.25.7
      wait: true
      waitTimeout: 5m
  - id: install-patch-provider
    type: chart
    with:
      name: patch-provider
      repository: https://charts.krateo.io
      set:
      - name: image.repository
        value: ghcr.io/krateoplatformops/patch-provider
      - name: image.pullPolicy
        value: IfNotPresent
      version: 1.0.0
      wait: true
      waitTimeout: 5m
  - id: install-composable-portal-basic
    type: chart
    with:
      name: composable-portal-basic
      repository: https://charts.krateo.io
      version: 0.3.1
      wait: true
      waitTimeout: 5m
  - id: extract-eventsse-internal-port
    type: var
    with:
      name: EVENTSSE_INTERNAL_PORT
      valueFrom:
        apiVersion: v1
        kind: Service
        metadata:
          name: eventsse-internal
        selector: .spec.ports[0].port
  - id: install-resource-tree-handler
    type: chart
    with:
      name: resource-tree-handler
      repository: https://charts.krateo.io
      set:
      - name: image.repository
        value: ghcr.io/krateoplatformops/resource-tree-handler
      - name: image.pullPolicy
        value: IfNotPresent
      - name: service.type
        value: NodePort
      - name: service.nodePort
        value: "30085"
      - name: env.URL_SSE
        value: http://eventsse-internal.krateo-system.svc.cluster.local:$EVENTSSE_INTERNAL_PORT/notifications
      - name: env.URL_PLURALS
        value: http://bff.krateo-system.svc.cluster.local:$BFF_INTERNAL_PORT/api-info/names
      version: 0.2.5
      wait: true
      waitTimeout: 5m
EOF
# Wait for the Krateo Platform to be ready

kubectl wait krateoplatformops krateo --for condition=Ready=True --timeout=600s --namespace krateo-system
