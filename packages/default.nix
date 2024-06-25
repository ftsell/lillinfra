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
          cat <<END
        # WireGuard Config File
        # See docs: https://man.archlinux.org/man/extra/wireguard-tools/wg-quick.8.en
        [Interface]
        PrivateKey = $PRIVKEY
        Address = ${builtins.head vpnData.ownIps}
        
        [Peer]
        PublicKey = ${data.wg_vpn.vpn-srv.pub}
        AllowedIPs = ${builtins.head data.wg_vpn.vpn-srv.routedIps}
        Endpoint = vpn.ftsell.de:51820
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
(pkgs.lib.attrsets.mapAttrs' mkVpnConfigFilePackage data.wg_vpn)
  // import ./custom_python.nix args
  // {

  # madara = pkgs.stdenv.mkDerivation rec {
  #   name = "madara";
  #   version = "1.7.4.1";
  #   src = pkgs.requireFile {
  #     name = "madara-${version}.zip";
  #     url = "https://mangabooth.com/";
  #     hash = "sha256-JxfjZLoN6I9twAQMT60Q27CgJg22G7zEU5GDra9rROs=";
  #   };
  #   nativeBuildInputs = [
  #     pkgs.unzip
  #   ];
  #   installPhase = "mkdir -p $out; cp -R * $out/";
  # };

  # madara-child = pkgs.stdenv.mkDerivation rec {
  #   name = "madara-child";
  #   version = "1.0.3";
  #   src = pkgs.requireFile {
  #     name = "madara-child-${version}.zip";
  #     url = "https://mangabooth.com/";
  #     hash = "sha256-h9w2TmX1nXaoP27b9DQ1jf6z1hTS5+BWtlz+Fprk5dQ=";
  #   };
  #   nativeBuildInputs = [
  #     pkgs.unzip
  #   ];
  #   unpackPhase = ''
  #     mkdir -p $out
  #     unzip $src "madara-child/*" -d $out
  #   '';
  #   installPhase = "mv $out/madara-child/* $out";
  # };
  # madara-core = pkgs.stdenv.mkDerivation rec {
  #   name = "madara-core";
  #   version = "1.7.4.1";
  #   src = pkgs.requireFile {
  #     name = "madara-core-${version}.zip";
  #     url = "https://mangabooth.com/";
  #     hash = "sha256-r22hGCDlVeYTOFlhfKoc3r4TtpZExJ2E2QP9ssRoJco=";
  #   };
  #   nativeBuildInputs = [
  #     pkgs.unzip
  #   ];
  #   installPhase = "mkdir -p $out; cp -R * $out/";
  # };
  # madara-shortcodes = pkgs.stdenv.mkDerivation rec {
  #   name = "madara-shortcodes";
  #   version = "1.5.5.9";
  #   src = pkgs.requireFile {
  #     name = "madara-shortcodes-${version}.zip";
  #     url = "https://mangabooth.com/";
  #     hash = "sha256-IW7C5DTzvt3ROFpfB21LY2wmdR45lNj9c8/THHCi6eY=";
  #   };
  #   nativeBuildInputs = [
  #     pkgs.unzip
  #   ];
  #   unpackPhase = ''
  #     mkdir -p $out
  #     unzip $src "madara-shortcodes/*" -d $out
  #   '';
  #   installPhase = "mv $out/madara-shortcodes/* $out";
  # };
  # option-tree-lean = pkgs.stdenv.mkDerivation rec {
  #   name = "option-tree-lean";
  #   version = "0";
  #   src = pkgs.requireFile {
  #     name = "option-tree-lean.zip";
  #     url = "https://mangabooth.com/";
  #     hash = "sha256-9u+MGdOarNdLtARWiJpw/hsMR9X8r0h5qugGir+amUI=";
  #   };
  #   nativeBuildInputs = [
  #     pkgs.unzip
  #   ];
  #   installPhase = "mkdir -p $out; cp -R * $out/";
  # };
  # option-tree = pkgs.stdenv.mkDerivation rec {
  #   name = "option-tree";
  #   version = "2.7.3";
  #   src = pkgs.fetchzip {
  #     url = "https://downloads.wordpress.org/plugin/option-tree.zip";
  #     hash = "sha256-+dPt8qJ4rkmSKrIXX5IiWO4zkFkR+Uapjlbx1g7KzKs=";
  #   };
  #   nativeBuildInputs = [
  #     pkgs.unzip
  #   ];
  #   installPhase = "mkdir -p $out; cp -R * $out/";
  # };
  # widget-logic = pkgs.stdenv.mkDerivation rec {
  #   name = "widget-logic";
  #   version = "5.10.4";
  #   src = pkgs.fetchzip {
  #     url = "https://downloads.wordpress.org/plugin/widget-logic.zip";
  #     hash = "sha256-J2NOth3q+IaPVhFT97arsNfjUPyTZF4Vvin1Cb+xnKw=";
  #   };
  #   nativeBuildInputs = [
  #     pkgs.unzip
  #   ];
  #   installPhase = "mkdir -p $out; cp -R * $out/";
  # };
}
