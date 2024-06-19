{ self, nixpkgs, inputs }:
let
  mkSystem = systemType: name: nixpkgs.lib.nixosSystem {
    system = builtins.replaceStrings [ "-unknown-" "-gnu" ] [ "-" "" ] systemType;
    specialArgs = inputs;
    modules = [
      inputs.disko.nixosModules.disko
      inputs.home-manager.nixosModules.home-manager

      ./${name}.nix

      {
        networking.hostName = builtins.head (nixpkgs.lib.strings.splitString "." name);
      }
    ];
  };
in
{
  hosting = mkSystem "x86_64-unknown-linux-gnu" "hosting.srv.ftsell.de";
  rt-hosting = mkSystem "x86_64-unknown-linux-gnu" "rt-hosting.srv.ftsell.de";
  main-srv = mkSystem "x86_64-unknown-linux-gnu" "main.srv.ftsell.de";
  mail-srv = mkSystem "x86_64-unknown-linux-gnu" "mail.srv.ftsell.de";
  vpn-srv = mkSystem "x86_64-unknown-linux-gnu" "vpn.srv.ftsell.de";
  nix-builder = mkSystem "x86_64-unknown-linux-gnu" "nix-builder";
  finnsLaptop = mkSystem "x86_64-unknown-linux-gnu" "finnsLaptop";
  factorio-z9 = mkSystem "x86_64-unknown-linux-gnu" "factorio.z9.ccchh.net";
}
