{ modulesPath, config, lib, pkgs, ... }:
let
  data.wg_vpn = import ../data/wg_vpn.nix;
  wgServer = data.wg_vpn.peers."vpn.srv.myroot.intern";
  wgSelf = data.wg_vpn.peers."nas.srv.myroot.intern";
in
{
  imports = [
    ../modules/hosting_guest.nix
    ../modules/base_system.nix
    ../modules/user_ftsell.nix
  ];

  # filesystem config (including zfs which adds additional mountpoints automatically)
  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.forceImportRoot = false;
  networking.hostId = "d1c39a07";
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
  };

  environment.systemPackages = with pkgs; [
    wireguard-tools
  ];

  # networking config
  networking.useDHCP = false;
  systemd.network = {
    enable = true;

    # default network interface
    networks.enp1s0 = {
      matchConfig = {
        Type = "ether";
        MACAddress = "52:54:00:2e:74:29";
      };
      networkConfig.IPv6AcceptRA = false;
      DHCP = "yes";
    };

    # vpn client config
    netdevs.wgVpn = {
      netdevConfig = {
        Kind = "wireguard";
        Name = "wgVpn";
      };
      wireguardConfig = {
        ListenPort = 51820;
        PrivateKeyFile = "/run/secrets/wg_vpn/privkey";
      };
      wireguardPeers = [{
        wireguardPeerConfig = {
          PublicKey = wgServer.pub;
          AllowedIPs = [ wgServer.ownIp4 wgServer.ownIp6 ] ++ wgServer.routedIp4 ++ wgServer.routedIp6;
          Endpoint = "10.0.10.11";
        };
      }];
    };
    networks.wgVpn = {
      matchConfig = {
        Name = "wgVpn";
      };
      address = [ wgSelf.ownIp4 wgSelf.ownIp6 ];
      routes = [
        {
          # direct ip4
          routeConfig = {
            Destination = wgServer.ownIp4;
          };
        }
        {
          # direct ip6
          routeConfig = {
            Destination = wgServer.ownIp6;
          };
        }
      ] ++
      # routed ip4
      (builtins.map
        (iRoute: {
          routeConfig = {
            Gateway = wgServer.ownIp4;
            Destination = iRoute;
          };
        })
        wgServer.routedIp4
      ) ++
      # routed ip6
      (builtins.map
        (iRoute: {
          routeConfig = {
            Gateway = wgServer.ownIp6;
            Destination = iRoute;
          };
        })
        wgServer.routedIp6
      )
      ;
    };
  };

  sops.secrets."wg_vpn/privkey" = {
    owner = "systemd-network";
  };

  # postgres config
  services.postgresql = {
    enable = true;
    enableTCPIP = true;
    ensureDatabases = [ "ftsell" ];
    ensureUsers = [{
      name = "ftsell";
      ensureDBOwnership = true;
      ensureClauses.superuser = true;
    }];
    authentication = ''
      host all all 10.0.10.0/24 md5
      host all all 2a10:9902:111:10::/64 md5
    '';
  };

  # nfs server config
  services.nfs.server = {
    enable = true;
    statdPort = 4000;
    lockdPort = 4001;
    mountdPort = 4002;
    exports = ''
      /srv/data/k8s 10.0.10.0/24(rw,mp,no_root_squash,crossmnt)
    '';
  };

  # open firewall for filesystem access
  networking.nftables.enable = true;
  networking.firewall = {
    allowedTCPPorts = [
      5432 # postgresql
      2049 # nfs
      config.services.nfs.server.statdPort
      config.services.nfs.server.lockdPort
      config.services.nfs.server.mountdPort
    ];
    allowedUDPPorts = [
      2049 # nfs
      51820 # wireguard
      config.services.nfs.server.statdPort
      config.services.nfs.server.lockdPort
      config.services.nfs.server.mountdPort
    ];
  };

  # DO NOT CHANGE
  # this defines the first version of NixOS that was installed on the machine so that programs with non-migratable data files are kept compatible
  home-manager.users.ftsell.home.stateVersion = "24.05";
  system.stateVersion = "24.05";
}
