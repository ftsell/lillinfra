{
  description = "finnfrastructure - ftsell's infrastructure configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-24.05";
    #nixpkgs.url = "github:nixos/nixpkgs?ref=53e81e790209e41f0c1efa9ff26ff2fd7ab35e27";
    nixpkgs-small.url = "github:nixos/nixpkgs?ref=nixos-24.05-small";
    nixpkgs-release.url = "github:nixos/nixpkgs?ref=release-24.05";

    # some helpers for writing flakes with less repitition
    flake-utils.url = "github:numtide/flake-utils";

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

    # secret management
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # lix package manager
    # https://lix.systems
    lix = {
      url = "git+https://git.lix.systems/lix-project/nixos-module.git?ref=release-2.90";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, ... }: rec {
    nixosConfigurations = import ./systems {
      inherit inputs;
    };
    packages = nixpkgs.lib.attrsets.genAttrs nixpkgs.lib.systems.flakeExposed (system: import ./packages {
      inherit system inputs;
      pkgs = nixpkgs.legacyPackages.${system};
    });

    # custom output shortcuts
    installer = nixpkgs.lib.genAttrs [ "x86_64-linux" "aarch64-linux" ] (system: (nixpkgs.legacyPackages.x86_64-linux.nixos [ ./installer-config.nix ]).isoImage);
    wg_vpn = (nixpkgs.lib.filterAttrs (pkgName: _: (builtins.substring 0 14 "wg_vpn-config-") != "") packages.x86_64-linux);

    devShells.x86_64-linux.default = nixpkgs.legacyPackages.x86_64-linux.mkShell {
      packages = with nixpkgs.legacyPackages.x86_64-linux; [
        fluxcd
        kubectl
        kustomize
        kubernetes-helm
        jq
        cmctl
      ];
    };
  };
}
