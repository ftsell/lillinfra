args@{ inputs, pkgs, system }:
let
  data.wg_vpn = import ../data/wg_vpn.nix;

  mkVpnConfigFilePackage = (systemName: vpnData: {
    name = "wg_vpn-config-${systemName}";
    value = pkgs.writeShellApplication {
      name = "show-wg-conf";
      runtimeInputs = with pkgs; [ qrencode sops ];
      text = ''
        if [[ ! -d "$HOME/Projects/finnfrastructure" ]]; then
          echo !!! "$HOME/Projects/finnfrastructure does not exist" !!!
          exit 1
        fi

        function show_qr() {
          make_conf | qrencode -t ansiutf8 -o -
        }

        function make_conf() {
          PRIVKEY=$(sops --decrypt --extract '["wg_vpn"]["privkey"]' "$HOME/Projects/finnfrastructure/data/secrets/${systemName}.yml")
          # See docs: https://man.archlinux.org/man/extra/wireguard-tools/wg-quick.8.en
          cat <<END
        [Interface]
        PrivateKey = $PRIVKEY
        Address = ${vpnData.ownIp4}
        Address = ${vpnData.ownIp6}
        
        [Peer]
        PublicKey = ${data.wg_vpn.peers.vpn-srv.pub}
        AllowedIPs = ${builtins.concatStringsSep "," (data.wg_vpn.peers.vpn-srv.routedIp4 ++ data.wg_vpn.peers.vpn-srv.routedIp6)}
        Endpoint = ${data.wg_vpn.peers.vpn-srv.endpoint}
        END
        }

        if [[ $# -eq 0 ]]; then
          set -- "--help"
        fi

        case $1 in
          --qrcode)
            show_qr
            exit
            ;;
          --conf)
            CONF=$(make_conf)
            echo "$CONF"
            exit
            ;;
          *)
            echo "show-wg-conf-${systemName}: Show the wireguard configuration for ${systemName}"
            echo ""
            echo "Usage: show-wg-conf-${systemName} [ --qrcode, --conf ]"
            echo "  --qcrode   renders a QR-Code onto the terminal"
            echo "  --conf    displays the connection configuration as wireguard.conf file"
            exit 1
            ;;
        esac
      '';
    };
  });
in
(pkgs.lib.attrsets.mapAttrs' mkVpnConfigFilePackage data.wg_vpn.peers)
  // import ./custom_python.nix args
