# FluxCD Deployment Configuration

[FluxCD](https://fluxcd.io/) is the GitOps operator that I use for my personal infrastructure.

Installation manifests were generated with `flux install --export --components="source-controller,kustomize-controller,notification-controller" > flux-install.yml`.
