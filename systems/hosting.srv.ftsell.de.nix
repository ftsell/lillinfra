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

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };

  environment.systemPackages = map lib.lowPrio [
    pkgs.curl
    pkgs.gitMinimal
  ];
  programs.fish.enable = true;

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPzGnNKyn6jmVxig4SRnTBfpi6okPU2aOHPwFnAPTxJm ftsell@ftsell.de"
  ];
  users.users.ftsell = {
    createHome = true;
    extraGroups = [ "wheel" ];
    home = "/home/ftsell";
    shell = pkgs.fish;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPzGnNKyn6jmVxig4SRnTBfpi6okPU2aOHPwFnAPTxJm ftsell@ftsell.de"
    ];
    hashedPassword = "$y$j9T$x55BKHAikhaUeAPN6GsCa/$uig7LwmWeodvbBKKMmlO7k/UbtU.Za6RuS.QI5O5ag9";
    isNormalUser = true;
  };

  networking.useDHCP = false;
  systemd.network = {
    enable = true;
    networks.myroot = {
      matchConfig = {
        MACAddress = "0c:c4:7a:8e:25:ae";
      };
      address = [ "37.153.156.125/24" ];
      gateway = [ "37.153.156.1" ];
    };
  };

  system.stateVersion = "23.11";
}
