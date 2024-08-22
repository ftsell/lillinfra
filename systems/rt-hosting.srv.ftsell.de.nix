{ modulesPath, config, lib, pkgs, ... }:
let
  data.network = import ../data/hosting_network.nix;
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
        "2a10:9906:1002:125::1/64"
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
        {
          # myroot network can be reached directly
          routeConfig = {
            Destination = "2a10:9906:1002::/64";
            # Metric = 512;
          };
        }
        # {
        #   # default IPv6 route for traffic coming from this server (low metric = high priority)
        #   routeConfig = {
        #     Destination = "::/0";
        #     Source = "2a10:9906:1002:125::1/128";
        #     Gateway = "2a10:9906:1002::1";
        #     # Metric = 512;
        #   };
        # }
      ];
    };
    networks.ethVMs = {
      matchConfig = {
        Type = "ether";
        MACAddress = "52:54:00:85:6c:df";
      };
      address = [
        "${data.network.guests.rt-hosting.ipv4}/32"
        "10.0.0.1/24"
      ];
      routes = (builtins.map
        (i: {
          routeConfig = {
            Destination = i.ipv4;
          };
        })
        data.network.routedGuests)
        ++ [
          {
            # The part of my own ip space that i am using for hosting on MyRoot
            routeConfig = {
              Destination = "2a10:9902:111::/56";
            };
          }
        ];
    };
  };

  networking.nftables.enable = true;
  networking.nat = {
    enable = true;
    externalInterface = "enp1s0";
    internalIPs = [ "10.0.0.0/24" ];
    forwardPorts = (
      lib.flatten
        (builtins.map
          (iGuest: builtins.map
            (
              iPort: {
                proto = iPort.proto;
                sourcePort = iPort.src;
                destination = "${iGuest.ipv4}:${builtins.toString iPort.dst}";
              }
            )
            iGuest.portForwards)
          data.network.natGuests));
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
        interfaces = [ "enp8s0" ];
      };
      lease-database = {
        name = "/var/lib/kea/dhcp4.leases";
        persist = true;
        type = "memfile";
      };
      rebind-timer = 2000;
      renew-timer = 1000;
      valid-lifetime = 4000;
      shared-networks = [{
        name = "vmNet";
        subnet4 = [
          # routed subnet
          {
            subnet = "37.153.156.168/29";
            pools = [
              {
                pool = "37.153.156.169 - 37.153.156.175";
              }
            ];
            reservations = (builtins.map
              (i: {
                hw-address = i.macAddress;
                ip-address = i.ipv4;
              })
              data.network.routedGuests);
            option-data = [
              {
                name = "domain-name-servers";
                data = "9.9.9.9";
              }
              {
                name = "routers";
                data = data.network.guests.rt-hosting.ipv4;
              }
            ];
          }
          # natted subnet
          {
            subnet = "10.0.0.0/24";
            pools = [{ pool = "10.0.0.0/24"; }];
            reservations = (builtins.map
              (i: {
                hw-address = i.macAddress;
                ip-address = i.ipv4;
              })
              data.network.natGuests);
            option-data = [
              {
                name = "domain-name-servers";
                data = "9.9.9.9";
              }
              {
                name = "routers";
                data = "10.0.0.1";
              }
            ];
          }
        ];
      }];
    };
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
