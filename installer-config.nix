{ modulesPath, lib, pkgs, ... }: {
  imports = [
    (modulesPath + "/installer/cd-dvd/installation-cd-minimal-new-kernel-no-zfs.nix")
  ];

  environment.systemPackages = map lib.lowPrio [
    pkgs.curl
    pkgs.git
    pkgs.bcachefs-tools
    pkgs.keyutils
  ];

  networking.hostName = "nixos-installer";
  system.installer.channel.enable = true;
  console.font = "${pkgs.terminus_font}/share/consolefonts/ter-u22n.psf.gz";
  console.keyMap = "de";

  # Enable flakes
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
    "repl-flake"
  ];

  # use iwd instead of wpa_supplicant because the CLI is more user-friendly
  networking.wireless.enable = false;
  networking.wireless.iwd.enable = true;

  # configure my own user account in the installer
  nix.settings.trusted-users = [ "root" "@wheel" ];
  services.getty.autologinUser = lib.mkForce "ftsell";
  programs.fish.enable = true;
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
}
