{ inputs }:
let
  mkSystem = systemType: name: nixpkgs: nixpkgs.lib.nixosSystem {
    system = builtins.replaceStrings [ "-unknown-" "-gnu" ] [ "-" "" ] systemType;
    specialArgs = inputs;
    modules = [
      inputs.disko.nixosModules.disko
      inputs.home-manager.nixosModules.home-manager
      inputs.sops-nix.nixosModules.default
      #inputs.lix.nixosModules.default

      ../modules/backup.nix
      ./${name}.nix

      (
        let
          fqdnParts = nixpkgs.lib.strings.splitString "." name;
        in
        {
          networking.hostName = builtins.head fqdnParts;
          networking.domain = (builtins.concatStringsSep "." (builtins.tail fqdnParts));
        }
      )
    ];
  };
in
{
  # exposed hosts at myroot
  "hosting.srv.ftsell.de" = mkSystem "x86_64-unknown-linux-gnu" "hosting.srv.ftsell.de" inputs.nixpkgs-small;
  "rt-hosting.srv.ftsell.de" = mkSystem "x86_64-unknown-linux-gnu" "rt-hosting.srv.ftsell.de" inputs.nixpkgs-small;
  "mail.srv.ftsell.de" = mkSystem "x86_64-unknown-linux-gnu" "mail.srv.ftsell.de" inputs.nixpkgs-small;
  "gtw.srv.ftsell.de" = mkSystem "x86_64-unknown-linux-gnu" "gtw.srv.ftsell.de" inputs.nixpkgs-small;

  # internal hosts at myroot
  "main.srv.myroot.intern" = mkSystem "x86_64-unknown-linux-gnu" "main.srv.mroot.intern" inputs.nixpkgs-small;
  "vpn.srv.myroot.intern" = mkSystem "x86_64-unknown-linux-gnu" "vpn.srv.myroot.intern" inputs.nixpkgs-small;
  "monitoring.srv.myroot.intern" = mkSystem "x86_64-unknown-linux-gnu" "monitoring.srv.myroot.intern" inputs.nixpkgs-small;

  # private systems
  finnsLaptop = mkSystem "x86_64-unknown-linux-gnu" "finnsLaptop" inputs.nixpkgs;

  # home systems
  "finnsWorkstation.home.private" = mkSystem "x86_64-unknown-linux-gnu" "finnsWorkstation" inputs.nixpkgs;

  # others
  "factorio.z9.ccchh.net" = mkSystem "x86_64-unknown-linux-gnu" "factorio.z9.ccchh.net" inputs.nixpkgs;
}
