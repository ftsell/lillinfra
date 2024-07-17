{ config, lib, ... }:
let
  data.wg_vpn = import ../data/wg_vpn.nix;

  vpn_servers = (builtins.attrValues
    (lib.filterAttrs (peerName: iPeer: peerName != config.networking.hostName && iPeer.endpoint != null)
      data.wg_vpn.peers));
in
{
  networking.wg-quick.interfaces.wgVpn = {
    privateKeyFile = "/run/secrets/wg_vpn/privkey";
    address = [
      data.wg_vpn.peers.${config.networking.hostName}.ownIp4
      data.wg_vpn.peers.${config.networking.hostName}.ownIp6
    ];
    peers = (
      builtins.map
        (iPeer: {
          publicKey = iPeer.pub;
          endpoint = iPeer.endpoint;
          allowedIPs = [ iPeer.ownIp4 iPeer.ownIp6 ] ++ iPeer.routedIp4 ++ iPeer.routedIp6;
          persistentKeepalive = (lib.mkIf data.wg_vpn.peers.${config.networking.hostName}.keepalive 25);
        })
        vpn_servers);
  };

  sops.secrets = {
    "wg_vpn/privkey" = {
      owner = "systemd-network";
    };
  };
}
