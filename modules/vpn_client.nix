{ config, lib, ... }:
let
  data.wg_vpn = import ../data/wg_vpn.nix;
in
{
  networking.wg-quick.interfaces.wgVpn = {
    privateKeyFile = "/run/secrets/wg_vpn/privkey";
    address = data.wg_vpn.${config.networking.hostName}.ip;
    peers = (
      builtins.map
        (iPeer: {
          publicKey = iPeer.pub;
          endpoint = iPeer.endpoint;
          allowedIPs = iPeer.ip;
        })
        (builtins.attrValues
          (lib.filterAttrs
            (peerName: iPeer: peerName != config.networking.hostName && (builtins.hasAttr "endpoint" iPeer))
            data.wg_vpn)));
  };

  sops.secrets = {
    "wg_vpn/privkey" = {
      owner = "systemd-network";
    };
  };
}
