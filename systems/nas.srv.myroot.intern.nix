{ modulesPath, config, lib, pkgs, ... }: {
  imports = [
    ../modules/extra_system_formats.nix
    ../modules/hosting_guest.nix
    ../modules/base_system.nix
    ../modules/user_ftsell.nix
  ];

  # boot config
  fileSystems = {
    # "/boot" = {
    #   device = "/dev/disk/by-label/esp";
    #   fsType = "vfat";
    #   options = [ "fmask=0077" "dmask=0077" ];
    # };
    # "/" = {
    #   device = "/dev/disk/by-label/nas-root";
    #   fsType = "ext4";
    # };
  };

  # networking config
  networking.useDHCP = false;
  systemd.network = {
    enable = true;
    networks.default-ether = {
      matchConfig = {
        Type = "ether";
      };
      DHCP = "yes";
    };
  };

  # DO NOT CHANGE
  # this defines the first version of NixOS that was installed on the machine so that programs with non-migratable data files are kept compatible
  home-manager.users.ftsell.home.stateVersion = "24.05";
  system.stateVersion = "24.05";
}