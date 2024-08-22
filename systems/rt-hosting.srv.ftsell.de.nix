{ modulesPath, config, lib, pkgs, ... }:
let
  data.network = import ../data/hosting_network.nix;

  mkVlanNetdev = name: vlan: {
    netdevConfig = {
      Name = name;
      Kind = "vlan";
    };
    vlanConfig = {
      Id = vlan;
    };
  };
  mkVlanNetwork = name: vlan: routedIp4s: {
    matchConfig = {
      Name = name;
      Kind = "vlan";
    };
    networkConfig = {
      Address = [ "10.0.${builtins.toString vlan}.1/24" "fe80:${builtins.toString vlan}::1/64" ];
    };
    routes = builtins.map
      (ip4: {
        routeConfig = {
          Destination = ip4;
        };
      })
      routedIp4s;
  };
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
      device = "/dev/disk/by-uuid/9A39-E1DA";
      fsType = "vfat";
      options = [ "fmask=0077" "dmask=0077" ];
    };
    "/" = {
      device = "/dev/disk/by-uuid/97a94901-3ccb-4eec-8bd0-bafd2fd8408a";
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

  networking.useDHCP = false;
  systemd.network = {
    enable = true;
    networks.ethMyRoot = {
      matchConfig = {
        Type = "ether";
        MACAddress = "52:54:00:af:bc:45";
      };
      networkConfig = {
        IPv4ProxyARP = true;
        IPv6ProxyNDP = true;
      };
      address = [
        "${data.network.guests.rt-hosting.ipv4}/32"
        "2a10:9906:1002:125::1/128"
      ];
      gateway = [
        "37.153.156.1"
      ];
      routes = [
        {
          # default gateway can always be reached directly
          routeConfig = {
            Destination = "37.153.156.1";
          };
        }
        {
          # hypervisor IPv6 can always be reached directly
          routeConfig = {
            Destination = "2a10:9906:1002:0:125::125/64";
          };
        }
      ];
    };

    networks.ethVMs = {
      matchConfig = {
        Type = "ether";
        MACAddress = "52:54:00:85:6c:df";
      };
      linkConfig = {
        RequiredForOnline = false;
      };
      networkConfig = {
        LinkLocalAddressing = false;
        VLAN = [ "vlanFinn" "vlanBene" "vlanPolygon" "vlanVieta" ];
      };
    };

    netdevs."vlanFinn" = mkVlanNetdev "vlanFinn" 100;
    networks."vlanFinn" = mkVlanNetwork "vlanFinn" 100 [ "37.153.156.169" "37.153.156.170" ];

    netdevs."vlanBene" = mkVlanNetdev "vlanBene" 101;
    networks."vlanBene" = mkVlanNetwork "vlanBene" 101 [ "37.153.156.172" ];

    netdevs."vlanPolygon" = mkVlanNetdev "vlanPolygon" 102;
    networks."vlanPolygon" = mkVlanNetwork "vlanPolygon" 102 [ "37.153.156.174" ];

    netdevs."vlanVieta" = mkVlanNetdev "vlanVieta" 103;
    networks."vlanVieta" = mkVlanNetwork "vlanVieta" 103 [ "37.153.156.173" ];
  };

  networking.nftables.enable = true;
  networking.nat = {
    enable = true;
    externalInterface = "enp1s0";
    internalIPs = [ "10.0.100.0/24" "10.0.101.0/24" "10.0.102.0/24" "10.0.103.0/24" ];
  };

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };

  services.qemuGuest.enable = true;

  services.bird2 = {
    enable = false;
    config = ''
      hostname "rt-hosting.srv.ftsell.de";
      debug protocols { states, events };
      debug channels { states, events };
      debug tables { states, events };

      filter is_in_my_net {
        if net = 2a10:9902:111::/48 then accept; else reject;
      }

      filter is_default_route {
        if net = ::/0 || net = 0.0.0.0/0 then accept; else reject;
      }

      protocol device {
        debug { states };
      }

      protocol static {
        ipv6;
        # my own IP space that is assigned here
        # route 2a10:9902:111::/56 via "enp8s0";

        # MyRoot ip space reachable via hypervisor (bgp peer is there so we need to define how to get there)
        # route 2a10:9906:1002::/64 via 2a10:9906:1002:0:125::125 via "enp1s0";
      }

      protocol bgp myroot4 {
        local 37.153.156.168 as 214493;
        neighbor 37.153.156.2 as 39409;
        multihop;

        ipv4 {
          import none;
          export none;
        };
      }

      protocol bgp myroot6 {
        local 2a10:9906:1002:125::1 as 214493;
        neighbor 2a10:9906:1002::2 as 39409;
        multihop;

        ipv6 {
          # import filter is_default_route;
          import filter is_default_route;
          export filter is_in_my_net;
        };
      }

      protocol kernel {
        debug all;
        # metric 1024;
        learn;
        ipv6 {
          import all;
          export none;
          # export filter {
          #   if source = RTS_BGP then accept; else reject;
          # };
        };
      }
    '';
  };

  services.kea.dhcp4 = {
    enable = true;
    settings = {
      interfaces-config = {
        interfaces = [ "vlanFinn" "vlanBene" "vlanPolygon" "vlanVieta" ];
      };
      lease-database = {
        name = "/var/lib/kea/dhcp4.leases";
        persist = true;
        type = "memfile";
      };
      rebind-timer = 2000;
      renew-timer = 1000;
      valid-lifetime = 4000;
      authoritative = true;
      option-data = [
        {
          name = "domain-name-servers";
          data = "9.9.9.9";
        }
        {
          name = "routers";
          data = "37.153.156.168";
        }
      ];
      shared-networks = [
        {
          # network for finn
          name = "finnNet";
          interface = "vlanFinn";
          subnet4 = [
            {
              subnet = "37.153.156.169/30";
              pools = [{ pool = "37.153.156.169 - 37.153.156.170"; }];
              reservations = [
                {
                  # main-srv
                  hw-address = "52:54:00:ba:63:25";
                  ip-address = "37.153.156.169";
                }
                {
                  # mail-srv
                  hw-address = "52:54:00:66:e2:38";
                  ip-address = "37.153.156.170";
                }
              ];
            }
            {
              subnet = "10.0.100.0/24";
              pools = [{ pool = "10.0.100.10 - 10.0.100.254"; }];
            }
          ];
        }

        {
          # network for bene
          name = "beneNet";
          interface = "vlanBene";
          subnet4 = [
            {
              subnet = "37.153.156.172/32";
              pools = [{ pool = "37.153.156.172 - 37.153.156.172"; }];
              reservations = [
                {
                  # bene-server
                  hw-address = "52:54:00:13:f8:f9";
                  ip-address = "37.153.156.172";
                }
              ];
            }
            {
              subnet = "10.0.101.0/24";
              pools = [{ pool = "10.0.101.10 - 10.0.101.254"; }];
            }
          ];
        }

        {
          # network for polygon
          name = "polygonNet";
          interface = "vlanPolygon";
          subnet4 = [
            {
              subnet = "37.153.156.174/32";
              pools = [{ pool = "37.153.156.174 - 37.153.156.174"; }];
              reservations = [
                {
                  # polygon-server
                  hw-address = "52:54:00:f9:64:31";
                  ip-address = "37.153.156.174";
                }
              ];
            }
            {
              subnet = "10.0.102.0/24";
              pools = [{ pool = "10.0.102.10 - 10.0.102.254"; }];
            }
          ];
        }

        {
          # network for vieta
          name = "vietaNet";
          interface = "vlanVieta";
          subnet4 = [
            {
              subnet = "37.153.156.173/32";
              pools = [{ pool = "37.153.156.173 - 37.153.156.173"; }];
              reservations = [
                {
                  # polygon-server
                  hw-address = "52:54:00:6d:0e:83";
                  ip-address = "37.153.156.173";
                }
              ];
            }
            {
              subnet = "10.0.103.0/24";
              pools = [{ pool = "10.0.103.10 - 10.0.103.254"; }];
            }
          ];
        }
      ];
    };
  };

  services.radvd = {
    enable = false;
    config = ''
      interface enp8s0 {     
        AdvSendAdvert on;

        prefix 2a10:9906:1002:125::/64 {
          # this is the only router so the prefix should be deprecated on router shutdown
          DeprecatePrefix on;
          AdvOnLink off;
        };

        AdvRASrcAddress {
          fe80::1;
        };
      };
    '';
  };

  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = "1";
    "net.ipv6.conf.all.forwarding" = "1";
  };

  # DO NOT CHANGE
  # this defines the first version of NixOS that was installed on the machine so that programs with non-migratable data files are kept compatible
  home-manager.users.ftsell.home.stateVersion = "24.05";
  system.stateVersion = "24.05";
}
