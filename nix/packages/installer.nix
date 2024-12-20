{
  inputs,
  pkgs,
  system,
  ...
}:
{
  installer =
    (inputs.nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = inputs;
      modules = [ ../systems/installer.nix ];
    }).config.system.build.isoImage;
}
