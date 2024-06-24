{
  description = "finnfrastructure - ftsell's infrastructure configuration";

  nixConfig.extra-substituters = [ "https://nix-community.cachix.org" ];
  nixConfig.extra-trusted-public-keys = [ "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=" ];

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-24.05";

    # support for special hardware quirks
    nixos-hardware.url = "github:NixOS/nixos-hardware";

    # dotfile (and user package) manager
    home-manager = {
      url = "github:nix-community/home-manager?ref=release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # disk partitioning description
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # make nixos configuration available as bootable disk images in more formats
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # secret management
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, ... }: rec {
    nixosConfigurations = import ./systems {
      inherit self inputs nixpkgs;
    };
    packages = nixpkgs.lib.attrsets.genAttrs nixpkgs.lib.systems.flakeExposed (system: import ./packages {
      inherit system inputs;
      pkgs = nixpkgs.legacyPackages.${system};
    });

    # custom output shortcuts
    installer = nixpkgs.lib.genAttrs [ "x86_64-linux" "aarch64-linux" ] (system: (nixpkgs.legacyPackages.x86_64-linux.nixos [ ./installer-config.nix ]).isoImage);
    wg_vpn = (nixpkgs.lib.filterAttrs (pkgName: _: (builtins.substring 0 14 "wg_vpn-config-") != "") packages.x86_64-linux);
  };
}
