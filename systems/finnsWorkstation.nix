{ modulesPath, config, lib, pkgs, home-manager, ... }: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ../modules/base_system.nix
    #../modules/gnome.nix
    ../modules/user_ftsell.nix
    #../modules/vscode.nix
    #../modules/vpn_client.nix
  ];

  # boot config
  boot.initrd.availableKernelModules = [ "xhci_pci" "nvme" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" "hid_roccat_isku" ];
  boot.initrd.kernelModules = [  ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/cfa942ff-75c5-4fe3-bc0d-7c50e1072f4a";
      fsType = "bcachefs";
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
  boot.loader.systemd-boot = {
    enable = true;
    configurationLimit = 10;
    editor = false;
  };
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = [ "bcachefs" ];

  # hardware config
  # services.xserver.videoDrivers = [ "nvidia" ];
  # hardware.opengl = {
  #   enable = true;
  #   driSupport = true;
  # };
  # hardware.nvidia = {
  #   modesetting.enable = true;
  #   open = false;
  #   nvidiaSettings = false;
  #   prime = {
  #     intelBusId = "PCI:0:2:0";
  #     nvidiaBusId = "PCI:1:0:0";
  #     offload = {
  #       enable = true;
  #       enableOffloadCmd = true;
  #     };
  #   };
  # };

  # additional packages
  environment.systemPackages = with pkgs; [
    nixpkgs-fmt
    virt-manager
    # libreoffice-fresh
    # evince
    ranger
    sops
    git-crypt
    gnupg
  ];


  virtualisation.podman = {
    enable = true;
    dockerSocket.enable = true;
    autoPrune.enable = true;
    dockerCompat = true;
  };
  services.printing.enable = true;
  services.earlyoom.enable = true;
  programs.gnupg.agent.enable = true;

  # sops.age.keyFile = /home/ftsell/.config/sops/age/keys.txt;

  # DO NOT CHANGE
  # this defines the first version of NixOS that was installed on the machine so that programs with non-migratable data files are kept compatible
  home-manager.users.ftsell.home.stateVersion = "24.05";
  system.stateVersion = "24.05";
}
