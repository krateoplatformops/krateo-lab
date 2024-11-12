## Create the Github Collaborators RestDefinition

Check the definition
```bash
cat /root/filesystem/collaborators-def.yaml
```{{exec}}

Notes that checking the path "/repository/{owner}/{repo}/collaborators/{username}/permission" in the [OAS specification provided](https://github.com/krateoplatformops/github-oas3/blob/0acbf9cea865e6723eb9d503bd2b868d146ba69b/collaborators.yaml#L141) it is specified an [override server](https://swagger.io/docs/specification/v3_0/api-host-and-base-path/#overriding-servers). In the specification provided it has been already populated with the url `http://github-plugin.krateo-system.svc.cluster.local:8080` that is the url exposed by the Service installed the step before.
Note that the oas specifications for the path has been generated as described in the [github-oas3-plugin README](https://github.com/krateoplatformops/github-oas3-plugin/blob/main/README.md).


Apply the definition

```bash
kubectl apply -f /root/filesystem/collaborators-def.yaml
```{{exec}}


Check for definition readyness:

```bash
kubectl wait restdefinitions gh-collaborators --for condition=Ready=True --namespace gh-system --timeout=300s
```{{exec}}
