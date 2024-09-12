{ config, nixos-generators, ... }: {
  imports = [
    nixos-generators.nixosModules.all-formats
  ];
}
