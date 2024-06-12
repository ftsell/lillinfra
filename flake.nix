{
  description = "finnfrastructure - ftsell's infrastructure configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-24.05";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, disko, ... }: {
    nixosConfigurations = import ./systems {
      inherit self inputs nixpkgs;
    };
  };

}
