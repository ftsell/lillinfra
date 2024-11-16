{ modulesPath, config, lib, pkgs, ... }:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ../modules/base_system.nix
    ../modules/user_ftsell.nix
  ];

  # boot config
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" "sr_mod" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.loader.grub = {
    enable = true;
    device = "/dev/disk/by-id/ata-WDC_WD120EFBX-68B0EN0_D7HE49WN";
  };

  fileSystems = {
    "/boot" = {
      device = "/dev/disk/by-uuid/D04D-F233";
      fsType = "vfat";
      options = [ "fmask=0077" "dmask=0077" ];
    };
    "/" = {
      device = "/dev/disk/by-uuid/f78f5d37-7a20-4f21-96b7-9756973b5dc5";
      fsType = "ext4";
    };
  };
  swapDevices = [{
    device = "/dev/disk/by-uuid/466977ff-8fe6-40ef-84dc-57c2dc29ec04";
  }];

  # networking config
  networking.useDHCP = false;

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };

  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = "1";
    "net.ipv6.conf.all.forwarding" = "1";
    "vm.swappiness" = "0";
  };

  virtualisation.libvirtd = {
    enable = true;
    onShutdown = "shutdown";
    parallelShutdown = 10;
  };
  users.users.ftsell.extraGroups = [ "libvirtd" ];

  environment.systemPackages = with pkgs; [
    bridge-utils
    traceroute
  ];

  # DO NOT CHANGE
  # this defines the first version of NixOS that was installed on the machine so that programs with non-migratable data files are kept compatible
  home-manager.users.ftsell.home.stateVersion = "24.05";
  system.stateVersion = "23.11";
  networking.hostId = "eaad9974";
}
