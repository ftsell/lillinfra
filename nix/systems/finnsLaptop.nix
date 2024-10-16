{ modulesPath, config, lib, pkgs, home-manager, ... }: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ../modules/base_system.nix
    ../modules/gnome.nix
    ../modules/user_ftsell.nix
    ../modules/dev_env.nix
  ];

  # boot config
  #boot.initrd.systemd.enable = true;
  boot.initrd.availableKernelModules = [ "xhci_pci" "nvme" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
  boot.kernelPackages = pkgs.linuxKernel.packages.linux_6_6;
  boot.kernelModules = [ "kvm-intel" ];
  boot.zfs.extraPools = [ "nvme" ];
  fileSystems = {
    "/" = {
      device = "nvme/root";
      fsType = "zfs";
      options = [ "zfsutil" ];
    };
    "/home" = {
      device = "nvme/home";
      fsType = "zfs";
      options = [ "zfsutil" ];
    };
    "/nix" = {
      device = "nvme/nix";
      fsType = "zfs";
      options = [ "zfsutil" ];
    };
    "/boot" = {
      device = "/dev/disk/by-uuid/5C6D-BE54";
      fsType = "vfat";
      options = [ "fmask=0077" "dmask=0077" ];
    };
  };
  swapDevices = [{
    device = "/dev/nvme0n1p2";
    randomEncryption.enable = true;
  }];
  hardware.cpu.intel.updateMicrocode = config.hardware.enableRedistributableFirmware;
  nixpkgs.hostPlatform = "x86_64-linux";
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot = {
    enable = true;
    configurationLimit = 10;
    editor = false;
  };

  # hardware config
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.opengl = {
    enable = true;
    driSupport = true;
  };
  hardware.nvidia = {
    modesetting.enable = true;
    nvidiaSettings = false;
    prime = {
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };
    };
    package = config.boot.kernelPackages.nvidiaPackages.mkDriver {
       version = "555.58.02";
       sha256_64bit = "sha256-xctt4TPRlOJ6r5S54h5W6PT6/3Zy2R4ASNFPu8TSHKM=";
       sha256_aarch64 = "sha256-wb20isMrRg8PeQBU96lWJzBMkjfySAUaqt4EgZnhyF8=";
       openSha256 = "sha256-8hyRiGB+m2hL3c9MDA/Pon+Xl6E788MZ50WrrAGUVuY=";
       settingsSha256 = "sha256-ZpuVZybW6CFN/gz9rx+UJvQ715FZnAOYfHn5jt5Z2C8=";
       persistencedSha256 = "sha256-a1D7ZZmcKFWfPjjH1REqPM5j/YLWKnbkP9qfRyIyxAw=";
     };
  };

  # backup settings
  custom.backup.rsync-net = {
   enable = true;
   repoPath = "./backups/private-systems";
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
    sieveshell
    nftables
    file
  ];

  virtualisation.podman = {
    enable = true;
    dockerSocket.enable = true;
    autoPrune.enable = true;
    dockerCompat = true;
  };
  services.printing.enable = true;
  services.earlyoom.enable = true;
  services.resolved.enable = true;
  programs.gnupg.agent.enable = true;

  sops.age.keyFile = /home/ftsell/.config/sops/age/keys.txt;

  # DO NOT CHANGE
  # this defines the first version of NixOS that was installed on the machine so that programs with non-migratable data files are kept compatible
  home-manager.users.ftsell.home.stateVersion = "24.05";
  system.stateVersion = "24.05";
  networking.hostId = "7b7a33ed";
}