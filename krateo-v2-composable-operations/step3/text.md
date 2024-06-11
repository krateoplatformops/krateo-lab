
Now we're getting serious! Let's install a `Composition` leveraging the `fireworksapp-tgz` CompositionDefinition.

Following the [README.me](https://github.com/krateoplatformops/krateo-v2-template-fireworksapp/blob/5a625b21d23f32eda3b03f1706b2eabb67810caa/README.md) let's prepare the Kubernetes cluster:

```plain
helm repo add krateo https://charts.krateo.io
helm repo update krateo
helm install github-provider krateo/github-provider --namespace krateo-system --create-namespace
helm install git-provider krateo/git-provider --namespace krateo-system --create-namespace
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update argo
helm install argocd argo/argo-cd --namespace krateo-system --create-namespace --wait
```{{exec}}

In order to interact with GitHub, we need a token. Let's change the token in the file /root/filesystem/github-repo-creds.yaml
using Killercoda IDE.

Once the manifest is modified, let's apply the manifest:

```plain
kubectl apply -f /root/filesystem/github-repo-creds.yaml
```{{exec}}

We are now able to create an instance of the composition.

<br>

```plain
cat <<EOF | kubectl apply -f -
apiVersion: composition.krateo.io/v0-1-0
kind: FireworksApp
metadata:
  name: fireworksapp-tgz
  namespace: krateo-system
spec:
  # @param {object} argocd ArgoCD parameters section
  argocd:
    # @param {string} namespace Namespace where ArgoCD has been installed
    namespace: krateo-system
    # @param {object} application ArgoCD application configuration section
    application:
      # @param {string} project ArgoCD Application project
      project: default
      # @param {object} source ArgoCD Application source parameters section
      source:
        # @param {string} path ArgoCD Application source path inside the repository created by the template
        path: chart/
      # @param {object} project ArgoCD Application destination parameters section
      destination:
        # @param {string} server ArgoCD Application target cluster
        server: https://kubernetes.default.svc
        # @param {string} namespace ArgoCD Application target namespace
        namespace: fireworks-app
      # @param {object} syncPolicy ArgoCD Application synchronization policies section
      syncPolicy:
        # @param {object} automated ArgoCD Application automated synchronization policies section
        automated:
          # @param {boolean} prune Prune specifies to delete resources from the cluster that are no longer tracked in git
          prune: true
          # @param {boolean} selfHeal SelfHeal specifies whether to revert resources back to their desired state upon modification in the cluster
          selfHeal: true

  # @param {object} app Helm Chart parameters section
  app:
    # @param {object} app Helm Chart service parameters section
    service:
      # @param {enum{NodePort,LoadBalancer}} app Helm Chart service type
      type: NodePort
      # @param {integer{min=30000,max=32767}} app Helm Chart service port
      port: 31180

  # @param {object} git Git Repository parameters section
  git:
    # @param {boolean} unsupportedCapabilities UnsupportedCapabilities enable Go-Git transport.UnsupportedCapabilities Azure DevOps requires capabilities multi_ack / multi_ack_detailed, which are not fully implemented in go-git library and by default are included in transport.UnsupportedCapabilities.
    unsupportedCapabilities: true
    # @param {enum{Delete,Orphan}} deletionPolicy DeletionPolicy specifies what will happen to the underlying external when this managed resource is deleted - either "Delete" or "Orphan" the external resource.
    deletionPolicy: Orphan
    # @param {boolean} insecure Insecure is useful with hand made SSL certs
    insecure: true
    # @param {object} fromRepo Parameters section for Git repository used as template for the application skeleton
    fromRepo:
      # @param {string} scmUrl (schema+host e.g. https://github.com) for the target Git repository
      scmUrl: https://github.com
      # @param {string} org Organization/group/subgroup for the target Git repository
      org: krateoplatformops
      # @param {string} name Name for the target Git repository
      name: krateo-v2-template-fireworksapp
      # @param {string} branch Branch of Git repository used as template for the application skeleton
      branch: main
      # @param {string} path Path of Git repository used as template for the application skeleton
      path: skeleton/
      # @param {object} credentials References to the secrets that contain the credentials required to clone the repository (in case of private ones)
      credentials:
        # @param {enum{basic,bearer}} authMethod AuthMethod defines the authentication mode. One of 'basic' or 'bearer'
        authMethod: basic
        # @param {object} secretRef Reference details about the secret where the credentials are stored
        secretRef:
          # @param {string} namespace Namespace of the secret where the credentials are stored
          namespace: krateo-system
          # @param {string} name Name of the secret where the credentials are stored
          name: github-repo-creds
          # @param {string} key Key of the secret to use
          key: token
    # @param {object} toRepo Parameters section for Git repository that will be created by Krateo
    toRepo:
      # @param {string} scmUrl (schema+host e.g. https://github.com) for the target Git repository
      scmUrl: https://github.com
      # @param {string} org Organization/group/subgroup for the target Git repository
      org: krateoplatformops-archive
      # @param {string} name Name for the target Git repository
      name: fireworksapp-test-v2
      # @param {string} branch Branch for the target Git repository
      branch: main
      # @param {string} path Path where the template will be placed
      path: /
      # @param {object} credentials References to the secrets that contain the credentials required to push the content the repository (in case of private ones)
      credentials:
        # @param {enum{basic,bearer}} authMethod AuthMethod defines the authentication mode. One of 'basic' or 'bearer'
        authMethod: basic
        # @param {object} secretRef Reference details about the secret where the credentials are stored
        secretRef:
          # @param {string} namespace Namespace of the secret where the credentials are stored
          namespace: krateo-system
          # @param {string} name Name of the secret where the credentials are stored
          name: github-repo-creds
          # @param {string} key Key of the secret to use
          key: token
      # @param {string} apiUrl URL to use for API
      apiUrl: https://api.github.com
      # @param {boolean} private Whether the repository is private
      private: false
      # @param {boolean} initialize Whether the repository must be initialized
      initialize: true
      # @param {enum{Delete,Orphan}} deletionPolicy DeletionPolicy specifies what will happen to the underlying external when this managed resource is deleted - either "Delete" or "Orphan" the external resource.
      deletionPolicy: Delete

EOF
```{{exec}}

Let's wait for the Composition `fireworksapp` to be Ready

```plain
kubectl wait fireworksapp fireworksapp-tgz --for condition=Ready=True --timeout=300s --namespace krateo-system
```{{exec}}

Check the Composition `fireworksapp-tgz` outputs

```plain
kubectl get fireworksapp fireworksapp-tgz --namespace krateo-system
```{{exec}}
