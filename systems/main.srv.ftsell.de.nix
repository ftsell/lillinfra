{ modulesPath, config, lib, pkgs, ... }:
let 
  data.network = import ../data/hosting_network.nix;
in {
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    ../modules/base_system.nix
    ../modules/user_ftsell.nix
  ];

  # boot config
  fileSystems = {
    "/boot" = {
      device = "/dev/disk/by-uuid/66AB-693B";
      fsType = "vfat";
      options = [ "fmask=0077" "dmask=0077" ];
    };
    "/" = {
      device = "/dev/disk/by-uuid/ef98ffbb-63c7-4338-929f-241ded7536e7";
      fsType = "bcachefs";
    };
  };

  boot.initrd.availableKernelModules = [ "ahci" "xhci_pci" "virtio_pci" "sr_mod" "virtio_blk" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];
  boot.loader.systemd-boot = {
    enable = true;
    configurationLimit = 10;
    editor = false;
  };

  # networking config
  networking.useDHCP = false;
  systemd.network = {
    enable = true;
    networks.enp1s0 = {
      matchConfig = {
        Type = "ether";
        MACAddress = data.network.guests.main-srv.macAddress;
      };
      DHCP = "yes";
    };
  };

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };

  # k8s config
  services.k3s = {
    enable = true;
    role = "server";
    clusterInit = true;
    # TODO add fc00:42::/64 as cluster-cidr and fc00:43::/64 as service-cidr once the server has its own ipv6 address
    extraFlags = "--disable-helm-controller --disable traefik --flannel-backend wireguard-native --cluster-cidr 10.42.0.0/16 --service-cidr 10.43.0.0/16 --egress-selector-mode disabled";
  };
  networking.firewall = {
    # https://docs.k3s.io/installation/requirements#networking
    allowedTCPPorts = [ 6443 10250 ];
    allowedUDPPorts = [ 51820 51821 ];
  };

  # DO NOT CHANGE
  # this defines the first version of NixOS that was installed on the machine so that programs with non-migratable data files are kept compatible
  home-manager.users.ftsell.home.stateVersion = "24.05";
  system.stateVersion = "24.05";
}
