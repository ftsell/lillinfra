{ modulesPath, config, lib, pkgs, ... }:
let
  data.network = import ../data/hosting_network.nix;
  data.wg_vpn = import ../data/wg_vpn.nix;
in
{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    ../modules/base_system.nix
    ../modules/user_ftsell.nix
  ];

  # boot config
  fileSystems = {
    "/boot" = {
      device = "/dev/disk/by-uuid/E9D6-069D";
      fsType = "vfat";
      options = [ "fmask=0077" "dmask=0077" ];
    };
    "/" = {
      device = "/dev/disk/by-uuid/27a157c7-50b0-4778-a9e2-2747cb59b5e0";
      fsType = "bcachefs";
    };
  };

  boot.initrd.availableKernelModules = [ "ahci" "xhci_pci" "virtio_pci" "sr_mod" "virtio_blk" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];
  boot.loader.systemd-boot = {
    enable = true;
    configurationLimit = 10;
    editor = false;
  };

  environment.systemPackages = with pkgs; [
    wireguard-tools
  ];

  # networking config
  networking.useDHCP = false;
  systemd.network = {
    enable = true;
    networks.enp1s0 = {
      matchConfig = {
        Type = "ether";
        MACAddress = data.network.guests.vpn-srv.macAddress;
      };
      DHCP = "yes";
    };
    netdevs.wgVpn = {
      netdevConfig = {
        Kind = "wireguard";
        Name = "wgVpn";
      };
      wireguardConfig = {
        ListenPort = 51820;
        PrivateKeyFile = "/run/secrets/wg_vpn/privkey";
      };
      wireguardPeers = (
        builtins.map
          (iPeer: {
            wireguardPeerConfig = {
              PublicKey = iPeer.pub;
              AllowedIPs = iPeer.ownIps;
                  Endpoint = lib.mkIf (builtins.hasAttr "endpoint" iPeer) iPeer.endpoint;
            };
          })
          (builtins.attrValues
            (lib.filterAttrs (peerName: iPeer: peerName != "vpn-srv")
              data.wg_vpn)));
    };
    networks.wgVpn = {
      matchConfig = {
        Name = "wgVpn";
      };
      address = data.wg_vpn.vpn-srv.ownIps;
    };
  };

  networking.firewall.allowedUDPPorts = [ 51820 ];

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };

  sops.secrets = {
    "wg_vpn/privkey" = {
      owner = "systemd-network";
    };
  };

  # DO NOT CHANGE
  # this defines the first version of NixOS that was installed on the machine so that programs with non-migratable data files are kept compatible
  home-manager.users.ftsell.home.stateVersion = "24.05";
  system.stateVersion = "24.05";
}
