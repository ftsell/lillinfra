{ modulesPath, config, lib, pkgs, home-manager, ... }: 
let
  vhostDefaults = {
    forceSSL = true;
    enableACME = true;
  };
in {
  imports = [
    ../modules/base_system.nix
    ../modules/hosting_guest.nix
    ../modules/user_ftsell.nix
    ../modules/vpn_client.nix
  ];

  # boot config
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/db0274b7-1d3a-4839-afcd-a4b662f52b79";
      fsType = "ext4";
    };
    "/boot" = {
      device = "/dev/disk/by-uuid/53AA-C797";
      fsType = "vfat";
      options = [ "fmask=0077" "dmask=0077" ];
    };
  };

  # network config
  networking.useDHCP = false;
  systemd.network = {
    enable = true;
    networks.enp1s0 = {
      matchConfig.Type = "ether";
      networkConfig.DHCP = "yes";
    };
  };

  networking.firewall.allowedTCPPorts = [ 80 443 ];
  networking.firewall.allowedUDPPorts = [ 80 443 ];

  # web server config
  security.acme = {
    acceptTerms = true;
    defaults.email = "webmaster@lly.sh";
  };
  
  services.nginx = {
    enable = true;
    recommendedTlsSettings = true;
    recommendedProxySettings = true;
    recommendedOptimisation = true;
    recommendedGzipSettings = true;
    virtualHosts = {

      "sync.home.lly.sh" = vhostDefaults // {
        serverAliases = [ "sync.home.ftsell.de" ];
        locations."/".proxyPass = "http://priv.srv.home.intern:8384";
      };

      #"ha.home.lly.sh" = vhostDefaults // {
      #  serverAliases = [ "ha.home.ftsell.de" ];
      #  locations."/" = {
      #    proxyPass = "http://home-assistant.srv.home.intern:8123";
      #    proxyWebsockets = true;
      #  };
      #};

      "docs.home.lly.sh" = vhostDefaults // {
        serverAliases = [ "docs.home.ftsell.de" ];
        locations."/".proxyPass = "http://priv.srv.home.intern:8000";
      };

      "pics.home.lly.sh" = vhostDefaults // {
        serverAliases = [ "pics.home.lly.sh" ];
        locations."/".proxyPass = "http://priv.srv.home.intern:3001";
      };
      
    };     
  };

  # DO NOT CHANGE
  # this defines the first version of NixOS that was installed on the machine so that programs with non-migratable data files are kept compatible
  home-manager.users.ftsell.home.stateVersion = "24.05";
  system.stateVersion = "24.05";
  networking.hostId = "1a091689";
}
