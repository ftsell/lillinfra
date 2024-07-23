{ modulesPath, config, lib, pkgs, ... }:
let
  data.network = import ../data/hosting_network.nix;
in
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ../modules/base_system.nix
    ../modules/user_ftsell.nix
  ];

  # boot config
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/88eabac5-5476-49c1-b5d6-dd1f29ff3660";
      fsType = "bcachefs";
    };
    "/boot" = {
      device = "/dev/disk/by-uuid/C85B-5816";
      fsType = "vfat";
      options = [ "fmask=0077" "dmask=0077" ];
    };
  };
  swapDevices = [{
    device = "/dev/disk/by-uuid/58ccf5a8-6b0f-45b3-bfe0-fe9db08b3338";
  }];

  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  boot.initrd.availableKernelModules = [ "xhci_pci" "ehci_pci" "ahci" "usbhid" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];
  boot.loader.grub = {
    enable = true;
    device = "/dev/disk/by-id/ata-WDC_WD120EFBX-68B0EN0_D7HE49WN";
  };

  # networking config
  networking.useDHCP = false;

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };

  systemd.network = {
    enable = true;

    # define a bridge device for physical network connections
    netdevs.brMyRoot = {
      netdevConfig = {
        Name = "brMyRoot";
        Description = "The bridge device connected to the physical network";
        Kind = "bridge";
        MACAddress = "0c:c4:7a:8e:25:ae";
      };
    };

    # instruct the physical ethernet adapter to use the brMyRoot bridge device
    networks.ethMyRoot = {
      matchConfig = {
        Type = "ether";
        MACAddress = "0c:c4:7a:8e:25:ae";
      };
      networkConfig = {
        Bridge = "brMyRoot";
      };
    };

    # assign IP addresses for the server itself on the bridge device
    networks.brMyRoot = {
      matchConfig = {
        Name = "brMyRoot";
      };
      address = [
        "37.153.156.125/24"
        "2a10:9906:1002:0:125::125/64"
      ];
      gateway = [
        "37.153.156.1"
        "2a10:9906:1002::1"
      ];
      routes = [
        {
          # rt-hosting IPv4 can always be reached
          routeConfig = {
            Destination = data.network.guests.rt-hosting.ipv4;
          };
        }
        {
          # rt-hosting IPv6 can always be reached
          routeConfig = {
            Destination = "2a10:9906:1002:125::1/128";
          };
        }
        {
          # myroot assigned IPv6 can be reached via rt-hosting's IPv6 address
          routeConfig = {
            Destination = "2a10:9906:1002:125::/64";
            Gateway = "2a10:9906:1002:125::1/128";
          };
        }
      ] ++ builtins.map
        (i: {
          routeConfig = {
            Destination = i.ipv4;
            Gateway = data.network.guests.rt-hosting.ipv4;
          };
        })
        data.network.routedGuests;
    };
  };

  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = "1";
    "net.ipv6.conf.all.forwarding" = "1";
  };

  systemd.timers.download-nixos-installer = {
    name = "download-nixos-installer.timer";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnActiveSec = "0";
      OnCalendar = "24hr";
    };
  };
  systemd.services.download-nixos-installer = {
    name = "download-nixos-installer.service";
    path = [ pkgs.curl ];
    script = "curl -sSL https://channels.nixos.org/nixos-24.05/latest-nixos-minimal-x86_64-linux.iso -o /var/lib/libvirt/images/nixos-installer-x86_64-linux.iso";
  };
  systemd.timers.download-debian-installer = {
    name = "download-debian-installer.timer";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnActiveSec = "0";
      OnCalendar = "24hr";
    };
  };
  systemd.services.download-debian-installer = {
    name = "download-debian-installer.service";
    path = [ pkgs.curl ];
    script = "curl -sSL https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-12.5.0-amd64-netinst.iso -o /var/lib/libvirt/images/debian-12-amd64-netinst.iso";
  };

  virtualisation.libvirtd = {
    enable = true;
    onShutdown = "shutdown";
    parallelShutdown = 10;
  };
  users.users.ftsell.extraGroups = [ "libvirtd" ];

  # backup config
  custom.backup.rsync-net = {
    enable = true;
  };

  # DO NOT CHANGE
  # this defines the first version of NixOS that was installed on the machine so that programs with non-migratable data files are kept compatible
  home-manager.users.ftsell.home.stateVersion = "24.05";
  system.stateVersion = "23.11";
}
