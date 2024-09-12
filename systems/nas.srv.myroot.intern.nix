{ modulesPath, config, lib, pkgs, ... }: {
  imports = [
    ../modules/hosting_guest.nix
    ../modules/base_system.nix
    ../modules/user_ftsell.nix
  ];

  # boot config
  fileSystems = {
    "/boot" = {
      device = "/dev/disk/by-uuid/C669-0126";
      fsType = "vfat";
      options = [ "fmask=0077" "dmask=0077" ];
    };
    "/" = {
      device = "/dev/disk/by-uuid/9ce95a64-55d6-442d-a41f-8bbbb3332269";
      fsType = "ext4";
    };
    "/srv/data/server-myroot" = {
      device = "/dev/disk/by-uuid/8cc75af5-bc8a-4366-bbea-a7ca7dd62e87";
      fsType = "bcachefs";
    };
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