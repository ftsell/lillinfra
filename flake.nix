{
  description = "finnfrastructure - ftsell's infrastructure configuration";

  nixConfig.extra-substituters = [ "https://nix-community.cachix.org" ];
  nixConfig.extra-trusted-public-keys = [ "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=" ];

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

    # prebuilt images of NixOS which output installation ISOs
    nixos-images.url = "github:nix-community/nixos-images";
    nixos-images.inputs.nixos-stable.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nixpkgs, nixos-images, ... }: {
    nixosConfigurations = import ./systems {
      inherit self inputs nixpkgs;
    };
    # installer = (nixpkgs.legacyPackages.${system}.nixos [ self.nixosModules.image-installer ]).config.system.build.isoImage;
    installer = nixpkgs.lib.genAttrs [ "x86_64-linux" "aarch64-linux" ] (system: (nixpkgs.legacyPackages.x86_64-linux.nixos [ ./installer-config.nix]).isoImage);
  };
}
