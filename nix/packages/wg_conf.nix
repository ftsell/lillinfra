{
  inputs,
  pkgs,
  system,
}:
let
  data.wg_vpn = import ../data/wg_vpn.nix;
  lib = inputs.nixpkgs.lib;

  mkVpnConfigFilePackage = (
    systemName: selfClientConf: {
      name = "wg_vpn-config-${systemName}";
      value = pkgs.writeShellApplication {
        name = "show-wg-conf";
        runtimeInputs = with pkgs; [
          qrencode
          sops
        ];
        text = ''
          if [[ ! -d "$HOME/Projects/lillinfra" ]]; then
            echo !!! "$HOME/Projects/lillinfra does not exist" !!!
            exit 1
          fi

          function show_qr() {
            make_conf | qrencode -t ansiutf8 -o -
          }

          function make_conf() {
            PRIVKEY=$(sops --decrypt --extract '["wg_vpn"]["privkey"]' "$HOME/Projects/lillinfra/nix/data/secrets/${systemName}.yml")
            # See docs: https://man.archlinux.org/man/extra/wireguard-tools/wg-quick.8.en
            cat <<END
          [Interface]
          PrivateKey = $PRIVKEY
          DNS = ${lib.strings.concatStringsSep "," data.wg_vpn.network.dns}
          ${lib.strings.concatLines (builtins.map (ip: "Address = ${ip}") selfClientConf.allowedIPs)}

          ${lib.strings.concatLines (
            builtins.map (server: ''
              [Peer]
              PublicKey = ${server.pubKey}
              AllowedIPs = ${lib.strings.concatStringsSep "," server.allowedIPs}
              Endpoint = ${server.endpoint}
              PersistentKeepalive = ${if selfClientConf.keepalive then "25" else "0"}
            '') (builtins.attrValues data.wg_vpn.knownServers)
          )}
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
    }
  );
in
(pkgs.lib.attrsets.mapAttrs' mkVpnConfigFilePackage data.wg_vpn.knownClients)
