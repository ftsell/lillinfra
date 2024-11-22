{ modulesPath, config, lib, pkgs, home-manager, ... }: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ../modules/sane_extra_config.nix
    ../modules/base_system.nix
    ../modules/gnome.nix
    ../modules/user_ftsell.nix
    ../modules/dev_env.nix
    ../modules/syncthing.nix
    ../modules/vpn_client.nix
  ];

  # boot config
  boot.initrd.availableKernelModules = [ "xhci_pci" "nvme" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" "hid_roccat_isku" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.zfs.extraPools = [ "lillyPc" ];
  fileSystems = {
    "/" = {
      device = "lillyPc/root";
      fsType = "zfs";
      options = [ "zfsutil" ];
    };
    "/nix" = {
      device = "lillyPc/nix";
      fsType = "zfs";
      options = [ "zfsutil" ];
    };
    "/home" = {
      device = "lillyPc/home";
      fsType = "zfs";
      options = [ "zfsutil" ];
    };
    "/boot" = {
      device = "/dev/disk/by-uuid/5620-B429";
      fsType = "vfat";
      options = [ "fmask=0077" "dmask=0077" ];
    };
  };
  swapDevices = [{
    device = "/dev/disk/by-partuuid/56505436-7b17-4613-8a53-0ce1cbcfb000";
    randomEncryption.enable = true;
  }];
  hardware.cpu.intel.updateMicrocode = config.hardware.enableRedistributableFirmware;
  nixpkgs.hostPlatform = "x86_64-linux";
  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    configurationLimit = 10;
    useOSProber = true;
    device = "nodev";
  };
  boot.loader.efi.canTouchEfiVariables = true;

  # hardware config
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.opengl = {
    enable = true;
    driSupport = true;
  };
  hardware.nvidia = {
    modesetting.enable = true;
    open = false;
    nvidiaSettings = false;
  };

  # additional packages
  environment.systemPackages = with pkgs; [
    nixpkgs-fmt
    virt-manager
    libreoffice-fresh
    evince
    ranger
    sops
    git-crypt
    gnupg
    mumble
    teams-for-linux
    openssl
    tree
    kicad
  ];

  # backup settings
  custom.backup.rsync-net = {
    enable = true;
    repoPath = "./backups/private-systems";
  };

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };

  virtualisation.podman = {
    enable = true;
    dockerSocket.enable = true;
    autoPrune.enable = true;
    dockerCompat = true;
  };
  services.printing.enable = true;
  services.earlyoom.enable = true;
  programs.gnupg.agent.enable = true;
  services.resolved.enable = true;
  hardware.sane = {
    enable = true;
    extraConfig."epson2" = ''
      net EPSON79DA90.home.private
    '';
  };
  custom.user-syncthing.enable = true;

  sops.age.keyFile = /home/ftsell/.config/sops/age/keys.txt;

  # DO NOT CHANGE
  # this defines the first version of NixOS that was installed on the machine so that programs with non-migratable data files are kept compatible
  home-manager.users.ftsell.home.stateVersion = "24.05";
  system.stateVersion = "24.05";
  networking.hostId = "0744a9ed";
}
