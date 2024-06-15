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
  finnsLaptop = mkSystem "x86_64-unknown-linux-gnu" "finnsLaptop";
  factorio-z9 = mkSystem "x86_64-unknown-linux-gnu" "factorio.z9.ccchh.net";
}
