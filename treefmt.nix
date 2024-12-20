{ pkgs, ... }:
{
  projectRootFile = "flake.nix";
  settings.global.on-unmatched = "info";
  programs.nixfmt.enable = true;
}
