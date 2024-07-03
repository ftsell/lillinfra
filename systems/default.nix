{ inputs }:
let
  mkSystem = systemType: name: nixpkgs: nixpkgs.lib.nixosSystem {
    system = builtins.replaceStrings [ "-unknown-" "-gnu" ] [ "-" "" ] systemType;
    specialArgs = inputs;
    modules = [
      inputs.disko.nixosModules.disko
      inputs.home-manager.nixosModules.home-manager
      inputs.sops-nix.nixosModules.default

      ./${name}.nix

      {
        networking.hostName = builtins.head (nixpkgs.lib.strings.splitString "." name);
      }
    ];
  };
in
{
  hosting = mkSystem "x86_64-unknown-linux-gnu" "hosting.srv.ftsell.de" inputs.nixpkgs-small;
  rt-hosting = mkSystem "x86_64-unknown-linux-gnu" "rt-hosting.srv.ftsell.de" inputs.nixpkgs-small;
  main-srv = mkSystem "x86_64-unknown-linux-gnu" "main.srv.ftsell.de" inputs.nixpkgs-small;
  mail-srv = mkSystem "x86_64-unknown-linux-gnu" "mail.srv.ftsell.de" inputs.nixpkgs-small;
  vpn-srv = mkSystem "x86_64-unknown-linux-gnu" "vpn-srv" inputs.nixpkgs-small;
  finnsLaptop = mkSystem "x86_64-unknown-linux-gnu" "finnsLaptop" inputs.nixpkgs;
  finnsWorkstation = mkSystem "x86_64-unknown-linux-gnu" "finnsWorkstation" inputs.nixpkgs;
  factorio-z9 = mkSystem "x86_64-unknown-linux-gnu" "factorio.z9.ccchh.net" inputs.nixpkgs;
}
