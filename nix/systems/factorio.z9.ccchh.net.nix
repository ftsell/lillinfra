{ modulesPath, config, lib, pkgs, ... }:
let
  myLib = import ../lib.nix { inherit lib pkgs; };
in
{
  imports = [
    ../modules/hosting_guest.nix
    ../modules/base_system.nix
    ../modules/user_ftsell.nix
  ];

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/5580383e-c67b-4b7c-8776-9b5867fb8daf";
      fsType = "ext4";
    };
    "/boot" = {
      device = "/dev/disk/by-uuid/7159-8B6F";
      fsType = "vfat";
      options = [ "fmask=0077" "dmask=0077" ];
    };
  };
  swapDevices = [{ 
    device = "/dev/disk/by-uuid/3a8d7425-6cef-4025-92a0-bad0b73dcf4e";
  }];

  networking.useDHCP = false;
  systemd.network = {
    enable = true;
    networks.ethMyRoot = {
      matchConfig = {
        Type = "ether";
        MACAddress = "bc:24:11:a3:43:7f";
      };
      networkConfig."DHCP" = "yes";
    };
  };

  # actual factorio config
  #services.factorio = {
  #  enable = true;
  #  game-name = "CCCHH Factorio";
  #  lan = true;
  #  saveName = "default-no-mods";
  #  requireUserVerification = false;
  #  openFirewall = true;
  #};
  
  # DO NOT CHANGE
  # this defines the first version of NixOS that was installed on the machine so that programs with non-migratable data files are kept compatible
  system.stateVersion = "24.05";
  home-manager.users.ftsell.home.stateVersion = "24.05";
}
