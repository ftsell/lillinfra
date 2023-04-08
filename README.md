# finnfrastructure

My personal infrastructure *configuration-as-code* repository.
Its goal is to contain all necessary configuration for my different servers to allow easier setup.

## Repo Structure

1. [terraform](./terraform) is the initial starting point.
   It provisions servers from Hetzner, configures cloud-init and cloud firewalls appropriately.

   Additionally, there is also a storage box involved which is not provisioned via Terraform because there is no 
   appropriate terraform provider.
2. [ansible](./ansible) takes over after terraform and configures the bare servers how they should operate.
   This includes setting up a Kubernetes cluster which is then used to run the actual application workloads.
3. [k8s](./k8s) marks the final configuration step since it contains all the application workloads that are supposed to
   be run on the system.
