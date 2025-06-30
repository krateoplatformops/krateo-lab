## Install Krateo and the Composable FinOps
Krateo is currently installing, along the Composable FinOps module. You can follow the [official Krateo Documentation](https://docs.krateo.io/how-to-guides/install-krateo/installing-krateo-kind) for further information on installing Krateo.

Wait for Krateo to be ready:
```plain
kubectl wait krateoplatformops krateo --for condition=Ready=True --namespace krateo-system --timeout=660s
```{{exec}}
This step might take upwards of 10 minutes, go grab a coffee in the meantime! :)

Note: this installation disables the Composable Operations and Composable Portal to avoid overloading the Killercoda environment.