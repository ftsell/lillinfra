{
  description = "lillinfra - lillys infrastructure configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-24.11";
    nixpkgs-small.url = "github:nixos/nixpkgs?ref=nixos-24.11-small";
    nixpkgs-release.url = "github:nixos/nixpkgs?ref=release-24.11";
    nixpkgs-local.url = "/home/ftsell/Projects/nixpkgs";

    # some helpers for writing flakes with less repitition
    flake-utils.url = "github:numtide/flake-utils";

    # support for special hardware quirks
    nixos-hardware.url = "github:NixOS/nixos-hardware";

    # dotfile (and user package) manager
    home-manager = {
      url = "github:nix-community/home-manager?ref=release-24.11";
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

    # more output formats for nixos images
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # lix package manager
    # https://lix.systems
    lix = {
      url = "git+https://git.lix.systems/lix-project/nixos-module.git?ref=release-2.91";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # nm-file-secret-agent
    nm-file-secret-agent = {
      url = "git+https://git.lly.sh/lilly/nm-file-secret-agent.git";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, ... }: rec {
    nixosConfigurations = import ./nix/systems { inherit inputs; };
    packages = nixpkgs.lib.attrsets.genAttrs nixpkgs.lib.systems.flakeExposed (system: import ./nix/packages {
      inherit system inputs;
      pkgs = nixpkgs.legacyPackages.${system};
    });

    devShells.x86_64-linux.default = nixpkgs.legacyPackages.x86_64-linux.mkShell {
      packages = with nixpkgs.legacyPackages.x86_64-linux; [
        fluxcd
        kubectl
        kustomize
        kubernetes-helm
        jq
        cmctl
        age
        ssh-to-age
        woodpecker-cli
        python311
        python311Packages.pynetbox
        python311Packages.ipython
        pre-commit
      ];
    };
  };
}
