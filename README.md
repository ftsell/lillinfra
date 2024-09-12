# finnfrastructure

My personal infrastructure *configuration-as-code* repository.
Its goal is to contain all necessary configuration for my different servers to allow easier setup.

### How to show a WireGuard config

Run the following command but substitue the `finnsLaptop` part for some other host:

```shell
set -l PKG (nix build --print-out-paths --no-link '.#packages.x86_64-linux.wg_vpn-config-finnsLaptop')
$PKG/bin/show-wg-conf
```

### How to generate an Installer ISO

Run the following command.
The resulting ISO file is then located in the printed path + `/iso`.

```shell
nix build --print-out-paths --no-link '.#installer.x86_64-linux'
```

### How to install a system

2. In the installer, create and mount filesystems.
3. Enter filesystem config into this repository for that server and commit changes.
   
   ```nix
    fileSystems = {
        "/boot" = {
            device = "/dev/disk/by-uuid/…";
            fsType = "vfat";
            options = [ "fmask=0077" "dmask=0077" ];
        };
        "/" = {
            device = "/dev/disk/by-uuid/…";
            fsType = "bcachefs";
        };
    };
   ```
4. Run nixos-install like this:

   ```shell
   sudo nixos-install --no-channel-copy --no-root-passwd --root /mnt --flake 'github:ftsell/finnfrastructure?ref=nix-config#…'
   ```
5. Reboot the system

### How to build a systems hard drive

If a system has nixos-generators enabled, its hard drive can be build using the following command:

```shell
nix build --no-link --print-out-paths '.#nixosConfigurations."nas.srv.myroot.intern".config.formats.qcow-efi'
```

### How to get the public age key of a host

```shell
nix-shell -p ssh-to-age --run 'ssh-keyscan example.com | ssh-to-age'
```

