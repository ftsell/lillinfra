{
  config,
  modulesPath,
  lib,
  pkgs,
  home-manager,
  sops-nix,
  lix,
  ...
}:
{
  imports = [
    (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix")
    home-manager.nixosModules.default
    sops-nix.nixosModules.default
    lix.nixosModules.lixFromNixpkgs
    ../modules/base_system.nix
    ../modules/user_ftsell.nix
  ];

  environment.systemPackages = with pkgs; [
    curl
    git
    bcachefs-tools
    keyutils
  ];

  networking.hostName = "nixos-installer";
  system.installer.channel.enable = true;

  # use iwd instead of wpa_supplicant because the CLI is more user-friendly
  networking.wireless.enable = false;
  networking.wireless.iwd.enable = true;

  # configure my own user account in the installer
  services.getty.autologinUser = lib.mkForce "ftsell";
  # programs.fish.enable = true;
  # users.users.ftsell = {
  #   createHome = true;
  #   extraGroups = [ "wheel" ];
  #   home = "/home/ftsell";
  #   shell = pkgs.fish;
  #   openssh.authorizedKeys.keys = [
  #     "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPzGnNKyn6jmVxig4SRnTBfpi6okPU2aOHPwFnAPTxJm ftsell@ftsell.de"
  #   ];
  #   hashedPassword = "$y$j9T$x55BKHAikhaUeAPN6GsCa/$uig7LwmWeodvbBKKMmlO7k/UbtU.Za6RuS.QI5O5ag9";
  #   isNormalUser = true;
  # };

  # this is only okay because the installer does not have any persistence so no data can be in an old/incompatible format
  system.stateVersion = config.system.nixos.release;
  home-manager.users.ftsell.home.stateVersion = config.system.stateVersion;
}
