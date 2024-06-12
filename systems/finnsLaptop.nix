{ modulesPath, config, lib, pkgs, ... }: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  disko.devices = builtins.trace modulesPath {
    disk.nvme = {
      device = "/dev/disk/by-id/nvme-SAMSUNG_MZVLW512HMJP-000H1_S36ENX0J824180_1";
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          esp = {
            size = "512M";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
            };
          };
          swap = {
            size = "16G";
            type = "8200";
            content = {
              type = "swap";
              randomEncryption = true;
            };
          };
          root = {
            size = "100%";
            type = "8308";
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

  hardware.cpu.intel.updateMicrocode = config.hardware.enableRedistributableFirmware;
  boot.loader.grub.enable = true;
  programs.fish.enable = true;
  environment.systemPackages = map lib.lowPrio [
    pkgs.curl
    pkgs.git
  ];

  users.users.ftsell = {
    createHome = true;
    extraGroups = [ "wheel" "networkmanager" ];
    home = "/home/ftsell";
    shell = pkgs.fish;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPzGnNKyn6jmVxig4SRnTBfpi6okPU2aOHPwFnAPTxJm ftsell@ftsell.de"
    ];
    hashedPassword = "$y$j9T$x55BKHAikhaUeAPN6GsCa/$uig7LwmWeodvbBKKMmlO7k/UbtU.Za6RuS.QI5O5ag9";
    isNormalUser = true;
  };

  networking.networkmanager.enable = true;

  system.stateVersion = "24.05";
}
