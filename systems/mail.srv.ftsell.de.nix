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
      device = "/dev/disk/by-uuid/9A1C-8830";
      fsType = "vfat";
      options = [ "fmask=0077" "dmask=0077" ];
    };
    "/" = {
      device = "/dev/disk/by-uuid/55cc058d-7b2b-4a01-ac2c-59ba6261bc8c";
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
        MACAddress = data.network.guests.mail-srv.macAddress;
      };
      DHCP = "yes";
    };
    networks.enp8s0 = {
      matchConfig = {
        Type = "ether";
        MACAddress = "52:54:00:7d:ff:7f";
      };
      DHCP = "yes";
      networkConfig = {
        IPv6AcceptRA = false;
      };
    };
  };

  # firewall
  networking.firewall = {
    # https://docs.k3s.io/installation/requirements#networking
    allowedTCPPorts = [
      10250 # kubelet metrics
      25 # mail smtp
      587 # mail submission
      993 # mail imap
      4190 # mail sieve-manage
    ];
    allowedUDPPorts = [
      8472 # k8s flannel vxlan
    ];
  };

  # k8s setup
  services.k3s = {
    enable = true;
    role = "agent";
    serverAddr = "https://10.0.10.15:6443";
    tokenFile = "/run/secrets/k3s/token";
  };
  sops.secrets."k3s/token" = { };

  # DO NOT CHANGE
  # this defines the first version of NixOS that was installed on the machine so that programs with non-migratable data files are kept compatible
  home-manager.users.ftsell.home.stateVersion = "24.05";
  system.stateVersion = "24.05";
}
