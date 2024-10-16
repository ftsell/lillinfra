{ config, lib, pkgs, ... }:
let
  data.wg_vpn = import ../data/wg_vpn.nix;

  vpn_servers = (builtins.attrValues
    (lib.filterAttrs (peerName: iPeer: peerName != config.networking.hostName && iPeer.endpoint != null)
      data.wg_vpn.peers));

  selfPeer = data.wg_vpn.peers.${config.networking.fqdnOrHostName};
in
{
  environment.systemPackages = with pkgs; [
    wireguard-tools
  ];

  networking.wg-quick.interfaces.wgVpn = {
    privateKeyFile = "/run/secrets/wg_vpn/privkey";
    address = [ selfPeer.ownIp4 selfPeer.ownIp6 ];
    dns = [ "10.20.30.1" "fc10:20:30::1" ];
    peers = (
      builtins.map
        (iPeer: {
          publicKey = iPeer.pub;
          endpoint = iPeer.endpoint;
          allowedIPs = [ iPeer.ownIp4 iPeer.ownIp6 ] ++ iPeer.routedIp4 ++ iPeer.routedIp6;
          persistentKeepalive = (lib.mkIf selfPeer.keepalive 25);
        })
        vpn_servers);
  };

  sops.secrets = {
    "wg_vpn/privkey" = {
      owner = "systemd-network";
    };
  };
}
