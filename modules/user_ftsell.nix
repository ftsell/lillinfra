{ modulesPath, config, lib, pkgs, home-manager, ... }:
let
  data.hosting_network = import ../data/hosting_network.nix;
in
{
  programs.fish.enable = true;

  users.users.ftsell = {
    createHome = true;
    extraGroups = [ "wheel" "networkmanager" ]
      ++ (if config.virtualisation.podman.dockerSocket.enable then [ "podman" ] else [ ]);
    home = "/home/ftsell";
    shell = pkgs.fish;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPzGnNKyn6jmVxig4SRnTBfpi6okPU2aOHPwFnAPTxJm ftsell@ftsell.de"
    ];
    hashedPassword = "$y$j9T$x55BKHAikhaUeAPN6GsCa/$uig7LwmWeodvbBKKMmlO7k/UbtU.Za6RuS.QI5O5ag9";
    isNormalUser = true;
  };

  home-manager.users.ftsell = {
    home.preferXdgDirectories = true;
    xdg.configFile = {
      "helix/config.toml".source = ../dotfiles/ftsell/helix/config.toml;
      "wezterm/wezterm,lua".source = ../dotfiles/ftsell/wezterm/wezterm.lua;
    };
    home.file = {
      ".ssh/config".source = ../dotfiles/ftsell/ssh/config;
    };
    programs.direnv = import ../dotfiles/ftsell/direnv;
    programs.ssh.enable = true;
    programs.git = import ../dotfiles/ftsell/git.nix { inherit lib pkgs; };
    programs.fish = import ../dotfiles/ftsell/fish.nix;
  };
}
