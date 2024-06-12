{
  description = "finnfrastructure - ftsell's infrastructure configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-24.05";

    # support for special hardware quirks
    nixos-hardware.url = "github:NixOS/nixos-hardware";

    # disk partitioning description
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # make nixos configuration available as bootable disk image
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # nixos installer
    nixos-anywhere = {
      url = "github:nix-community/nixos-anywhere";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.disko.follows = "disko";
    };

    # prebuilt images of NixOS which output installation ISOs
    nixos-images.url = "github:nix-community/nixos-images";

  };

  outputs = inputs@{ self, nixpkgs, disko, ... }: {
    nixosConfigurations = import ./systems {
      inherit self inputs nixpkgs;
    };
  };

}
