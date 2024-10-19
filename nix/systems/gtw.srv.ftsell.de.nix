{ modulesPath, config, lib, pkgs, ... }: {
  imports = [
    ../modules/hosting_guest.nix
    ../modules/base_system.nix
    ../modules/user_ftsell.nix
  ];

  # boot config
  fileSystems = {
    "/boot" = {
      device = "/dev/disk/by-uuid/A38E-17CC";
      fsType = "vfat";
      options = [ "fmask=0077" "dmask=0077" ];
    };
    "/" = {
      device = "/dev/disk/by-uuid/2802674f-bd98-44b8-ab13-3292515e21e1";
      fsType = "ext4";
    };
  };

  # networking config
  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = "1";
  };

  networking.useDHCP = false;
  systemd.network = {
    enable = true;
    networks.enp1s0 = {
      matchConfig = {
        Type = "ether";
        MACAddress = "52:54:00:43:ff:c6";
      };
      DHCP = "yes";
    };
    networks.enp7s0 = {
      matchConfig = {
        Type = "ether";
        MACAdreess = "52:54:00:8c:88:66";
      };
      DHCP = "yes";
      networkConfig = {
        IPv6AcceptRA = false;
      };
    };
  };

  services.openssh.ports = [ 23 ];

  networking.nftables.enable = true;
  networking.nat = {
    enable = true;
    externalIP = "37.153.156.169";
    internalIPs = [ "10.0.10.0/24" ];
    externalInterface = "enp1s0";
    forwardPorts = [
      {
        # VPN
        proto = "udp";
        sourcePort = 51820;
        destination = "10.0.10.11:51820";
      }
      {
        # k8s api
        proto = "tcp";
        sourcePort = 6443;
        destination = "10.0.10.15:6443";
      }
      {
        # forgejo ssh
        proto = "tcp";
        sourcePort = 22;
        destination = "10.0.10.16:30022";
      }
    ];
  };

  networking.firewall.allowedTCPPorts = [ 80 443 ];

  # haproxy
  services.haproxy = {
    enable = true;
    config = ''
      defaults
        timeout connect 500ms
        timeout server 1h
        timeout client 1h

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
        server k8s-worker1 10.0.10.16:30080 check send-proxy

      backend ingress-https
        mode tcp
        server k8s-worker1 10.0.10.16:30443 check send-proxy
    '';
  };

  # DO NOT CHANGE
  # this defines the first version of NixOS that was installed on the machine so that programs with non-migratable data files are kept compatible
  home-manager.users.ftsell.home.stateVersion = "24.05";
  system.stateVersion = "24.05";
}
