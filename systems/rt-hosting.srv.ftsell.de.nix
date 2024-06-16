{ modulesPath, config, lib, pkgs, ... }: {
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    ../modules/base_system.nix
    ../modules/user_ftsell.nix
  ];

  # boot config
  fileSystems = {
    "/boot" = {
      device = "/dev/disk/by-uuid/9A39-E1DA";
      fsType = "vfat";
      options = [ "fmask=0077" "dmask=0077" ];
    };
    "/" = {
      device = "/dev/disk/by-uuid/97a94901-3ccb-4eec-8bd0-bafd2fd8408a";
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

  networking.useDHCP = false;
  systemd.network = {
    enable = true;
    networks.ethMyRoot = {
      matchConfig = {
        Type = "ether";
        MACAddress = "52:54:00:af:bc:45";
      };
      networkConfig = {
        DHCP = "no";
      };
      address = [
        "37.153.156.168/32"
      ];
      gateway = [
        "37.153.156.1"
      ];
      routes = [
        {
          routeConfig = {
            Destination = "37.153.156.1";
          };
        }
      ];
    };
    networks.ethVMs = {
      matchConfig = {
        Type = "ether";
        MACAddress = "52:54:00:85:6c:df";
      };
      address = [
        "37.153.156.168/29"
      ];
      # routes = builtins.map
      #   (i: {
      #     routeConfig = {
      #       Destination = i;

      #     };
      #   }) [
      #   "37.153.156.175"
      #   "37.153.156.174"
      #   "37.153.156.173"
      #   "37.153.156.172"
      #   "37.153.156.171"
      #   "37.153.156.170"
      #   "37.153.156.169"
      # ];
    };
  };

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };

  services.kea.dhcp4 = {
    enable = true;
    settings = {
      interfaces-config = {
        interfaces = [ "enp8s0" ];
      };
      lease-database = {
        name = "/var/lib/kea/dhcp4.leases";
        persist = true;
        type = "memfile";
      };
      rebind-timer = 2000;
      renew-timer = 1000;
      subnet4 = [
        {
          subnet = "37.153.156.168/29";
          pools = [
            {
              "pool" = "37.153.156.169 - 37.153.156.175";
            }
          ];
          option-data = [
            {
              name = "domain-name-servers";
              data = "9.9.9.9";
            }
            {
              name = "routers";
              data = "37.153.156.168";
            }
          ];
        }
      ];
      valid-lifetime = 4000;
    };
  };

  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = "1";
    "net.ipv6.conf.all.forwarding" = "1";
  };

  # DO NOT CHANGE
  # this defines the first version of NixOS that was installed on the machine so that programs with non-migratable data files are kept compatible
  home-manager.users.ftsell.home.stateVersion = "24.05";
  system.stateVersion = "24.05";
}
