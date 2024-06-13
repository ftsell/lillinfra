{ self, nixpkgs, inputs }:
let
  mkSystem = systemType: name: nixpkgs.lib.nixosSystem {
    system = builtins.replaceStrings [ "-unknown-" "-gnu" ] [ "-" "" ] systemType;
    specialArgs = inputs;
    modules = [
      inputs.disko.nixosModules.disko
      ./${name}.nix
      {
        networking.hostName = builtins.head (nixpkgs.lib.strings.splitString "." name);
        nix.settings.tarball-ttl = 60;
      }
    ];
  };
in
{
  hosting = mkSystem "x86_64-unknown-linux-gnu" "hosting.srv.ftsell.de";
  finnsLaptop = mkSystem "x86_64-unknown-linux-gnu" "finnsLaptop";
  factorio-z9 = mkSystem "x86_64-unknown-linux-gnu" "factorio.z9.ccchh.net";
}
