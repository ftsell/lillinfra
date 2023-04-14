## Get Access to the Kubernetes Cluster

To get access to our kubernetes cluster you need to run the corresponding ansible playbook that sets up appropriate
credential key material and then configure your local *kubectl* client to access the cluster.

1. **Create and download key material:**

   The playbook will automatically prompt you for all necessary inputs.
   ```shell
   ansible-playbook playbooks/get_access.yml
   ```

2. **Configure local kubectl:**

   The playbook execution should have placed key material into your home directory.
   You now need to tell *kubectl* to use that key material as well as tell it where the cluster is located.

   To do so, **run these commands from your home directory**:
   ```shell
   # replace <your-username> with the one chosen in the playbook
   export K8S_USER=<your-username>

   kubectl config set-cluster ftsell_de \
    --embed-certs \
    --server=https://main.srv.ftsell.de:6443 \
    --certificate-authority=ca.crt

   kubectl config set-credentials ${K8S_USER}@ftsell_de \
    --embed-certs \
    --client-key=user-${K8S_USER}.key \
    --client-certificate=user-${K8S_USER}.crt

   kubectl config set-context ftsell_de --cluster=ftsell_de --user=${K8S_USER}@ftsell_de

   kubectl config use-context ftsell_de
   ```

3. **Clean up local files**

   If you like your home directory to not be full of random files, you can now safely remove the previously used files
   from it:
   ```shell
   rm ca.crt user-${K8S_USER}.key user-${K8S_USER}.crt
   ```
