{lib, pkgs, config, ... }: 
with lib;
let
  cfg = config.custom.user-syncthing;
in {
  options = {
    custom.user-syncthing = {
      enable = mkEnableOption "this host to be a syncthing peer";
    };
  };

  config = {
    services.syncthing = lib.mkIf cfg.enable {
      enable = true;
      group = "users";
      user = "ftsell";
      dataDir = "/home/ftsell/";
      settings.options.urAccepted = -1;
      openDefaultPorts = false;
      overrideFolders = false;
      overrideDevices = false;
    };

    environment.systemPackages = mkIf config.services.xserver.enable [ pkgs.syncthingtray ];
  };
}
