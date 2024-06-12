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
      }
    ];
  };
in
{
  hosting = mkSystem "x86_64-unknown-linux-gnu" "hosting.srv.ftsell.de";
}
