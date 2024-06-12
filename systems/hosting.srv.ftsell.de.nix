{ modulesPath, config, lib, pkgs, ... }: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  disko.devices = {
    disk.disk1 = {
      device = "/dev/disk/by-id/ata-WDC_WD120EFBX-68B0EN0_D7HE49WN";
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          mbr = {
            size = "1M";
            type = "EF02";
            priority = 1;
          };
          boot = {
            name = "boot";
            size = "500M";
            type = "8300";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
            };
          };
          swap = {
            size = "8G";
            content = {
              type = "swap";
              randomEncryption = true;
            };
          };
          root = {
            name = "root";
            size = "100%";
            content = {
              type = "filesystem";
              format = "bcachefs";
              mountpoint = "/";
            };
          };
        };
      };
    };
  };

  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  boot.initrd.availableKernelModules = [ "xhci_pci" "ehci_pci" "ahci" "usbhid" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];
  boot.loader.grub.enable = true;

  networking.useDHCP = false;

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };

  environment.systemPackages = map lib.lowPrio [
    pkgs.curl
    pkgs.git
  ];
  programs.fish.enable = true;

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPzGnNKyn6jmVxig4SRnTBfpi6okPU2aOHPwFnAPTxJm ftsell@ftsell.de"
  ];
  users.users.ftsell = {
    createHome = true;
    extraGroups = [ "wheel" "libvirtd" ];
    home = "/home/ftsell";
    shell = pkgs.fish;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPzGnNKyn6jmVxig4SRnTBfpi6okPU2aOHPwFnAPTxJm ftsell@ftsell.de"
    ];
    hashedPassword = "$y$j9T$x55BKHAikhaUeAPN6GsCa/$uig7LwmWeodvbBKKMmlO7k/UbtU.Za6RuS.QI5O5ag9";
    isNormalUser = true;
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
        DHCP = "no";
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
        "2a10:9906:1002:0::1"
      ];
    };
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
    script = "curl -sSL https://github.com/nix-community/nixos-images/releases/download/nixos-24.05/nixos-installer-x86_64-linux.iso -o /var/lib/libvirt/images/nixos-installer-x86_64-linux.iso";
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

  nix.settings.tarball-ttl = 60;
  nix.settings.trusted-users = [ "root" "@wheel" ];

  virtualisation.libvirtd = {
    enable = true;
    onShutdown = "shutdown";
    parallelShutdown = 10;
  };

  system.stateVersion = "23.11";
}
