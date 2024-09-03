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
      Address = [ "10.0.${builtins.toString vlan}.1/24" "fe80::1/64" ];
      IPv6AcceptRA = false;
    };
    routes = (builtins.map
      (ip4: {
        routeConfig = {
          Destination = ip4;
        };
      })
      routedIp4s) ++ [{
      routeConfig = {
        Destination = "2a10:9902:111:${builtins.toString vlan}::/64";
      };
    }];
  };
in
{
  imports = [
    ../modules/hosting_guest.nix
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

  environment.systemPackages = with pkgs; [
    traceroute
  ];

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
      };
      address = [
        "${data.network.guests.rt-hosting.ipv4}/32"
        "2a10:9906:1002:0:125::126/64"
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

    netdevs."vlanFinn" = mkVlanNetdev "vlanFinn" 10;
    networks."vlanFinn" = mkVlanNetwork "vlanFinn" 10 [ "37.153.156.169" "37.153.156.170" ];

    netdevs."vlanBene" = mkVlanNetdev "vlanBene" 11;
    networks."vlanBene" = mkVlanNetwork "vlanBene" 11 [ "37.153.156.172" ];

    netdevs."vlanPolygon" = mkVlanNetdev "vlanPolygon" 12;
    networks."vlanPolygon" = mkVlanNetwork "vlanPolygon" 12 [ "37.153.156.174" ];

    netdevs."vlanVieta" = mkVlanNetdev "vlanVieta" 13;
    networks."vlanVieta" = mkVlanNetwork "vlanVieta" 13 [ "37.153.156.173" ];
  };

  networking.nftables.enable = true;
  networking.nat = {
    enable = true;
    externalInterface = "enp1s0";
    internalIPs = [ "10.0.10.0/24" "10.0.11.0/24" "10.0.12.0/24" "10.0.13.0/24" ];
  };

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };

  services.bird2 = {
    enable = true;
    config = ''
      hostname "rt-hosting.srv.ftsell.de";
      debug protocols { states, events };
      debug channels { states, events };
      debug tables { states, events };

      filter is_default_route {
        if net = ::/0 || net = 0.0.0.0/0 then accept; else reject;
      }

      protocol device {
        debug { states };
      }

      protocol static {
        ipv6;
        route 2a10:9902:111::/48 via "enp1s0";
      }

      protocol bgp myroot4 {
        local 37.153.156.168 as 214493;
        neighbor 37.153.156.2 as 39409;
        direct;
        graceful restart on;

        ipv4 {
          import none;
          export none;
        };
      }

      protocol bgp myroot6 {
        local 2a10:9906:1002:0:125::126 as 214493;
        neighbor 2a10:9906:1002::2 as 39409;
        direct;
        graceful restart on;

        ipv6 {
          import filter is_default_route;
          export filter {
            if source = RTS_STATIC then accept; else reject;
          };
        };
      }

      protocol kernel {
        debug all;
        graceful restart on;

        ipv6 {
          import all;
          export filter {
            if source = RTS_BGP then accept; else reject;
          };
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
                  # gtw.srv.ftsell.de
                  hw-address = "52:54:00:43:ff:c6";
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
              subnet = "10.0.10.0/24";
              pools = [{ pool = "10.0.10.10 - 10.0.10.254"; }];
              reservations = [
                {
                  # gtw.srv.myroot.intern
                  hw-address = "52:54:00:8c:88:66";
                  ip-address = "10.0.10.2";
                }
                {
                  # main.srv.myroot.intern
                  hw-address = "52:54:00:ba:63:25";
                  ip-address = "10.0.10.10";
                }
                {
                  # vpn.srv.myroot.intern
                  hw-address = "52:54:00:8e:97:05";
                  ip-address = "10.0.10.11";
                }
                {
                  # mail.srv.myroot.intern
                  hw-address = "52:54:00:7d:ff:7f";
                  ip-address = "10.0.10.12";
                }
              ];
              option-data = [{
                name = "routers";
                data = "10.0.10.2";
              }];
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
              subnet = "10.0.11.0/24";
              pools = [{ pool = "10.0.11.10 - 10.0.11.254"; }];
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
              subnet = "10.0.12.0/24";
              pools = [{ pool = "10.0.12.10 - 10.0.12.254"; }];
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
              subnet = "10.0.13.0/24";
              pools = [{ pool = "10.0.13.10 - 10.0.13.254"; }];
            }
          ];
        }
      ];
    };
  };

  services.radvd = {
    enable = true;
    config = ''
      interface vlanFinn {     
        AdvSendAdvert on;
        prefix 2a10:9902:111:10::/64 {};
      };

      interface vlanBene {
        AdvSendAdvert on;
        prefix 2a10:9902:111:11::/64 {};
      };

      interface vlanPolygon {
        AdvSendAdvert on;
        prefix 2a10:9902:111:12::/64 {};
      };

      interface vlanVieta {
        AdvSendAdvert on;
        prefix 2a10:9902:111:13::/64 {};
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
