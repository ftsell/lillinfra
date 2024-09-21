{ modulesPath, config, lib, pkgs, ... }:
let
  data.network = import ../data/hosting_network.nix;
in
{
  imports = [
    ../modules/hosting_guest.nix
    ../modules/base_system.nix
    ../modules/user_ftsell.nix
  ];

  # boot config
  fileSystems = {
    "/boot" = {
      device = "/dev/disk/by-uuid/94A7-6995";
      fsType = "vfat";
      options = [ "fmask=0077" "dmask=0077" ];
    };
    "/" = {
      device = "/dev/disk/by-uuid/4e0b7ea5-8c74-478f-a4e3-ddc5691e4065";
      fsType = "ext4";
    };
    "/srv/data/services" = {
      device = "10.0.10.14:/srv/data/services";
      fsType = "nfs";
      options = [ "defaults" "_netdev" ];
    };
  };

  # networking config
  networking.useDHCP = false;
  systemd.network = {
    enable = true;
    networks.enp1s0 = {
      matchConfig = {
        Type = "ether";
        Kind = "!veth";
      };
      networkConfig = {
        IPv6AcceptRA = false;
      };
      DHCP = "yes";
    };
  };

  # kubernetes setup
  services.k3s = {
    enable = true;
    role = "server";
    clusterInit = false;
    extraFlags = "--disable-helm-controller --disable=traefik --disable=servicelb --disable=local-storage --flannel-backend wireguard-native --cluster-cidr 10.42.0.0/16 --service-cidr 10.43.0.0/16 --egress-selector-mode disabled --tls-san=k8s.ftsell.de";
  };

  # DO NOT CHANGE
  # this defines the first version of NixOS that was installed on the machine so that programs with non-migratable data files are kept compatible
  home-manager.users.ftsell.home.stateVersion = "24.05";
  system.stateVersion = "24.05";
}
