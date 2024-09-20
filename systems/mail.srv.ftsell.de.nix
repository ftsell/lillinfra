{ modulesPath, config, lib, pkgs, ... }:
let 
  data.network = import ../data/hosting_network.nix;
in {
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

  # haproxy
  services.haproxy = {
    enable = false;
    config = ''
      defaults
        timeout connect 500ms
        timeout server 5000ms
        timeout client 20000ms

      frontend http
        bind :80
        mode tcp
        use_backend ingress-http
      
      frontend https
        bind :443
        mode tcp
        use_backend ingress-https

      backend ingress-http
        mode tcp
        server s1 127.0.0.1:30080 check send-proxy

      backend ingress-https
        mode tcp
        server s1 127.0.0.1:30443 check send-proxy
    '';
  };

  # k8s config
  services.k3s = {
    enable = false;
    role = "agent";
    serverAddr = "https://10.0.10.10:6443";
    extraFlags = "--node-taint ip-reputation=mailserver:NoExecute --node-taint ip-reputation=mailserver:NoSchedule";
    tokenFile = "/run/secrets/k3s/token";
  };
  networking.firewall = {
    # https://docs.k3s.io/installation/requirements#networking
    allowedTCPPorts = [ 6443 10250 80 443 25 587 993 4190 ];
    allowedUDPPorts = [ 51820 51821 ];
  };

  sops.secrets = {
    "k3s/token" = {};
  };

  # DO NOT CHANGE
  # this defines the first version of NixOS that was installed on the machine so that programs with non-migratable data files are kept compatible
  home-manager.users.ftsell.home.stateVersion = "24.05";
  system.stateVersion = "24.05";
}
