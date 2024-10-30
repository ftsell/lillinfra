{ modulesPath, config, lib, pkgs, home-manager, ... }: {
  imports = [
    ../modules/base_system.nix
    ../modules/hosting_guest.nix
    ../modules/user_ftsell.nix
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

  # caddy web server config
  services.caddy = {
    enable = true;
    enableReload =  true;
    email = "li@lly.sh";
    globalConfig = ''
      grace_period 10s
    '';

    virtualHosts = {
      "sync.home.lly.sh" = {
        serverAliases = [ "sync.home.ftsell.de" ];
        extraConfig = ''
          reverse_proxy http://priv.srv.home.intern:8384
        '';
      };

      "ha.home.lly.sh" = {
        serverAliases = [ "ha.home.ftsell.de" ];
        extraConfig = ''
          reverse_proxy http://home-assistant.srv.home.intern:8123
        '';
      };
    };
  };

  # DO NOT CHANGE
  # this defines the first version of NixOS that was installed on the machine so that programs with non-migratable data files are kept compatible
  home-manager.users.ftsell.home.stateVersion = "24.05";
  system.stateVersion = "24.05";
  networking.hostId = "1a091689";
}
