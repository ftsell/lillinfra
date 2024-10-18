{ modulesPath, config, lib, pkgs, ... }:
let
  data.network = import ../data/hosting_network.nix;

  mkBridgeNetdev = name: {
    netdevConfig = {
      Name = name;
      Kind = "bridge";
    };
    bridgeConfig = {
      STP = true;
    };
  };

  mkBridgeNetwork = name: {
    matchConfig = {
      Name = name;
      Kind = "bridge";
    };
    linkConfig = {
      RequiredForOnline = false;
      ActivationPolicy = "up";
    };
    networkConfig = {
      LinkLocalAddressing = false;
      ConfigureWithoutCarrier = true;
    };
  };

  mkVeth = name: {
    netdevConfig = {
      Name = "${name}-up";
      Description = "veth device for connecting a tenant (down) to brVMs (up)";
      Kind = "veth";
    };
    peerConfig = {
      Name = "${name}-down";
    };
  };

  mkVethConnUp = name: vlan: {
    matchConfig = {
      Name = "${name}-up";
    };
    networkConfig = {
      Bridge = "brVMs";
    };
    bridgeVLANs = [{
      bridgeVLANConfig = {
        VLAN = vlan;
        EgressUntagged = vlan;
        PVID = vlan;
      };
    }];
  };

  mkVethConnDown = vethName: brName: {
    matchConfig = {
      Name = "${vethName}-down";
    };
    networkConfig = {
      Bridge = brName;
    };
  };
in
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ../modules/base_system.nix
    ../modules/user_ftsell.nix
  ];

  # boot config
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    boot.initrd.availableKernelModules = [ "xhci_pci" "ehci_pci" "ahci" "usbhid" "sd_mod" ];
    boot.kernelModules = [ "kvm-intel" ];
    boot.loader.grub = {
      enable = true;
      device = "/dev/disk/by-id/ata-WDC_WD120EFBX-68B0EN0_D7HE49WN";
    };
  boot.zfs.extraPools = [ "hdd" ];
  fileSystems = {
    "/" = {
      device = "hdd/root";
      fsType = "zfs";
      options = [ "zfsutil" ];
    };
    "/nix" = {
      device = "hdd/nix";
      fsType = "zfs";
      options = [ "zfsutil" ];
    };
    "/boot" = {
      device = "/dev/disk/by-uuid/C85B-5816";
      fsType = "vfat";
      options = [ "fmask=0077" "dmask=0077" ];
    };
  };
  swapDevices = [{
    device = "/dev/disk/by-uuid/58ccf5a8-6b0f-45b3-bfe0-fe9db08b3338";
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

  systemd.network = {
    enable = true;

    # define a bridge device for physical network connections
    netdevs.brMyRoot = {
      netdevConfig = {
        Name = "brMyRoot";
        Description = "The bridge device connected to the physical network";
        Kind = "bridge";
        MACAddress = "0c:c4:7a:8e:25:ae";
      };
      bridgeConfig = {
        MulticastSnooping = false;
      };
      bridgeConfig = {
        STP = true;
      };
    };

    # define a 'master' bridge device to which the routing vm and all tenants are connected
    netdevs.brVMs = {
      netdevConfig = {
        Name = "brVMs";
        Kind = "bridge";
      };
      bridgeConfig = {
        STP = true;
        VLANFiltering = true;
      };
    };
    networks.brVMs = mkBridgeNetwork "brVMs";

    # define bridge device and connection for finn (me)
    netdevs.brFinn = mkBridgeNetdev "brFinn";
    networks.brFinn = mkBridgeNetwork "brFinn";
    netdevs.vethFinn = mkVeth "vethFinn";
    networks."vethFinn-up" = mkVethConnUp "vethFinn" 10;
    networks."vethFinn-down" = mkVethConnDown "vethFinn" "brFinn";

    netdevs.brBene = mkBridgeNetdev "brBene";
    networks.brBene = mkBridgeNetwork "brBene";
    netdevs.vethBene = mkVeth "vethBene";
    networks."vethBene@up" = mkVethConnUp "vethBene" 11;
    networks."vethBene@down" = mkVethConnDown "vethBene" "brBene";

    netdevs.brPolygon = mkBridgeNetdev "brPolygon";
    networks.brPolygon = mkBridgeNetwork "brPolygon";
    netdevs.vethPolygon = mkVeth "vethPoly";
    networks."vethPolygon@up" = mkVethConnUp "vethPoly" 12;
    networks."vethPolygon@down" = mkVethConnDown "vethPoly" "brPolygon";

    netdevs.brVieta = mkBridgeNetdev "brVieta";
    networks.brVieta = mkBridgeNetwork "brVieta";
    netdevs.vethVieta = mkVeth "vethVieta";
    networks."vethVieta@up" = mkVethConnUp "vethVieta" 13;
    networks."vethVieta@down" = mkVethConnDown "vethVieta" "brVieta";

    netdevs.brTimon = mkBridgeNetdev "brTimon";
    networks.brTimon = mkBridgeNetwork "brTimon";
    netdevs.vethTimon = mkVeth "vethTimon";
    networks."vethTimon@up" = mkVethConnUp "vethTimon" 14;
    networks."vethTimon@down" = mkVethConnDown "vethTimon" "brTimon";

    netdevs.brIsabell = mkBridgeNetdev "brIsabell";
    networks.brIsabell = mkBridgeNetwork "brIsabell";
    netdevs.vethIsabell = mkVeth "vethIsa";
    networks."vethIsa@up" = mkVethConnUp "vethIsa" 15;
    networks."vethIsa@down" = mkVethConnDown "vethIsa" "brIsabell";

    # instruct the physical ethernet adapter to use the brMyRoot bridge device
    networks.ethMyRoot = {
      matchConfig = {
        Type = "ether";
        MACAddress = "0c:c4:7a:8e:25:ae";
      };
      networkConfig = {
        Bridge = "brMyRoot";
      };
    };

    # assign IP addresses for the server itself on the bridge device
    networks.brMyRoot = {
      matchConfig = {
        Name = "brMyRoot";
      };
      address = [
        "37.153.156.125/24"
        "2a10:9906:1002:0:125::125/64"
      ];
      gateway = [
        "37.153.156.1"
        "2a10:9906:1002::1"
      ];
      routes = [
        {
          # rt-hosting IPv4 can always be reached
          routeConfig = {
            Destination = data.network.guests.rt-hosting.ipv4;
          };
        }
        # {
        #   # myroot routed IPv6 can be reached via rt-hosting's IPv6 address
        #   routeConfig = {
        #     Destination = "2a10:9906:1002:125::/64";
        #     Gateway = "2a10:9906:1002:125::1";  <- wrong
        #   };
        # }
      ] ++ builtins.map
        (i: {
          routeConfig = {
            Destination = i.ipv4;
            Gateway = data.network.guests.rt-hosting.ipv4;
          };
        })
        data.network.routedGuests;
    };
  };

  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = "1";
    "net.ipv6.conf.all.forwarding" = "1";
    "vm.swappiness" = "0";
  };

  systemd.timers.download-nixos-installer = {
    name = "download-nixos-installer.timer";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnActiveSec = "0";
      OnCalendar = "24hr";
    };
  };
  systemd.services.download-nixos-installer = {
    name = "download-nixos-installer.service";
    path = [ pkgs.curl ];
    script = "curl -sSL https://channels.nixos.org/nixos-24.05/latest-nixos-minimal-x86_64-linux.iso -o /var/lib/libvirt/images/nixos-installer-x86_64-linux.iso";
  };
  systemd.timers.download-debian-installer = {
    name = "download-debian-installer.timer";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnActiveSec = "0";
      OnCalendar = "24hr";
    };
  };
  systemd.services.download-debian-installer = {
    name = "download-debian-installer.service";
    path = [ pkgs.curl ];
    script = "curl -sSL https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-12.5.0-amd64-netinst.iso -o /var/lib/libvirt/images/debian-12-amd64-netinst.iso";
  };

  virtualisation.libvirtd = {
    enable = true;
    onShutdown = "shutdown";
    parallelShutdown = 10;
    hooks.qemu =
      let
        configure-bridge-vlan-port = pkgs.writeShellApplication {
          name = "qemu-configure-bridge-vlan-port";
          runtimeInputs = with pkgs; [ xmlstarlet ];
          text = ''
            # Docs: https://www.libvirt.org/hooks.html#etc-libvirt-hooks-network
            #
            # Assigns configugres the brVMs network device to allow all tenant VLANs to be forwarded to the routing vm
            # DOMAIN=$1
            OPERATION=$2
            # SUB_OPERATION=$3

            echo "DOMAIN=$1    OPERATION=$2    SUB_OPERATION=$3" >&2
            DOMAIN_XML="$(xmlstarlet select -t -c /domain -)"

            case $OPERATION in
              start)
                IFACE_COUNT=0
                while true; do
                  ((++IFACE_COUNT))
                  IFACE_XML="$(echo "$DOMAIN_XML" | xmlstarlet select -t -c "/domain/devices/interface[$IFACE_COUNT]" || exit 0)"
                  if [[ -z "$IFACE_XML" ]]; then
                      # finished
                      exit 0
                  fi

                  echo "$IFACE_XML" >&2
                  SOURCE_IFACE_NAME="$(echo "$IFACE_XML" | xmlstarlet select -t -v /interface/source/@network)"
                  TARGET_IFACE_NAME="$(echo "$IFACE_XML" | xmlstarlet select -t -v /interface/target/@dev)"
                  if [[ "$SOURCE_IFACE_NAME" = "brVMs" ]]; then
                    echo "Enabling VLANs 10-99 for bridge port $TARGET_IFACE_NAME" >&2
                    bridge vlan add vid 10-99 dev "$TARGET_IFACE_NAME"
                  else
                    echo "Ignoring interface $TARGET_IFACE_NAME (bridged to $SOURCE_IFACE_NAME)" >&2
                  fi
                done
                ;;
              *)
                echo "qemu hook does not handle operation $OPERATION*" >&2
                ;;
            esac
          '';
        };
      in
      {
        configure-bridge-vlan-port = "${configure-bridge-vlan-port}/bin/qemu-configure-bridge-vlan-port";
      };
  };
  users.users.ftsell.extraGroups = [ "libvirtd" ];

  environment.systemPackages = with pkgs; [
    bridge-utils
    traceroute
  ];

  # backup config
  custom.backup.rsync-net = {
    enable = true;
  };

  # DO NOT CHANGE
  # this defines the first version of NixOS that was installed on the machine so that programs with non-migratable data files are kept compatible
  home-manager.users.ftsell.home.stateVersion = "24.05";
  system.stateVersion = "23.11";
  networking.hostId = "eaad9974";
}
