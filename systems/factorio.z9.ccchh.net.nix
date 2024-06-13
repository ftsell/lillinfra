{ modulesPath, config, lib, pkgs, ... }:
let
  myLib = import ../lib.nix { inherit lib pkgs; };
in
{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  disko.devices = {
    disk.disk1 = {
      device = "/dev/vda";
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
            size = "2G";
            type = "8200";
            content = {
              type = "swap";
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

  boot.initrd.availableKernelModules = [ "ata_piix" "uhci_hcd" "ahci" "virtio_pci" "sr_mod" "virtio_blk" ];
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
    pkgs.htop
  ];
  programs.fish.enable = true;

  users.users.ftsell = {
    createHome = true;
    extraGroups = [ "wheel" ];
    home = "/home/ftsell";
    shell = pkgs.fish;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPaVpSL8G9Gs16bSNn9tDl29PiN0SwYZuYCMkp9baSua ftsell@ccc"
    ];
    hashedPassword = "$y$j9T$x55BKHAikhaUeAPN6GsCa/$uig7LwmWeodvbBKKMmlO7k/UbtU.Za6RuS.QI5O5ag9";
    isNormalUser = true;
  };

  systemd.network = {
    enable = true;
    networks.ethMyRoot = {
      matchConfig = {
        Type = "ether";
        MACAddress = "bc:24:11:a3:43:7f";
      };
      networkConfig = {
        DHCP = "yes";
      };
    };
  };

  nix.settings.trusted-users = [ "root" "@wheel" ];
  nixpkgs.config.allowUnfree = true;
  system.stateVersion = "24.05";

  # actual factorio config
  services.factorio = {
    enable = true;
    game-name = "CCCHH Factorio";
    lan = true;
    saveName = "default-no-mods";
    requireUserVerification = false;
    openFirewall = true;
  };
}
