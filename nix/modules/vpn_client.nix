{ config, lib, pkgs, ... }:
let
  data.wg_vpn = import ../data/wg_vpn.nix;

  selfClientConf = data.wg_vpn.knownClients."${config.networking.fqdnOrHostName}";
in
{
  environment.systemPackages = with pkgs; [
    wireguard-tools
  ];

  networking.wg-quick.interfaces.wgVpn = {
    privateKeyFile = "/run/secrets/wg_vpn/privkey";
    address = selfClientConf.allowedIPs;
    dns = data.wg_vpn.network.dns;
    peers = (
      builtins.map
        (iServer: {
          publicKey = iServer.pubKey;
          endpoint = iServer.endpoint;
          allowedIPs = iServer.allowedIPs;
          persistentKeepalive = (lib.mkIf selfClientConf.keepalive 25);
        })
        (builtins.attrValues data.wg_vpn.knownServers));
  };

  sops.secrets = {
    "wg_vpn/privkey" = {
      owner = "systemd-network";
    };
  };
}
