# FluxCD Deployment Configuration

[FluxCD](https://fluxcd.io/) is the GitOps operator that I use for my personal infrastructure.

Installation manifests were generated with `flux install --export --components="source-controller,kustomize-controller,notification-controller" > flux-install.yml`.

## Add new Kustomization Deployment

FluxCD already knows about the *finnfrastructure* repository so new deployments that are stored in a subdirectory of it can be added to it via the following command:

```shell
flux create kustomization --export \
  --source=GitRepository/finnfrastructure \
  --path="$PATH" \
  --prune \
  $NAME >> cd-config.yml
```
