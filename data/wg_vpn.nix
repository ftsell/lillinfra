#
# Definition of the networking topology of my WireGuard-VPN
#
# This module exposes an AttrSet keyed by a clients hostname
#

let
  mkClient = ipSuffix: keepalive: pub: {
    ownIp4 = "10.20.30.${ipSuffix}/32";
    ownIp6 = "fc10:20:30::${ipSuffix}/128";
    routedIp4 = [ ];
    routedIp6 = [ ];
    endpoint = null;
    inherit pub keepalive;
  };
  mkServer = endpoint: ownIpSuffix: routedIp4: routedIp6: pub: {
    ownIp4 = "10.20.30.${ownIpSuffix}/32";
    ownIp6 = "fc10:20:30::${ownIpSuffix}/128";
    keepalive = false;
    inherit endpoint routedIp4 routedIp6 pub;
  };
in
{
  peers = {
    vpn-srv = mkServer "vpn.ftsell.de:51820" "1" [ "10.20.30.0/24" ] [ "fc10:20:30::/64" ] "SRVfDEjWZCEcxynQoK1iibpzVeDN61ghTEQPps3pmSY=";
    finnsLaptop = mkClient "101" false "LAPcOludjQrjfza0M+XA+fuwxpVfmqRKjBawAxWDyDY=";
    finnsPhone = mkClient "102" false "PHN5Srlsv3x7+ehWF4SPz0eezcYlm7c0pIU5jXYuYG4=";
    home-proxy = mkServer "home.ftsell.de:51820" "103" [ ] [ ] "GTWotNqG3way+5NacVVs9bDwbLXplo/afSwZzU2XzkU=";
    finnsWorkstation = mkClient "104" false "WOrk7yTwmWilfWrOhF2EpmMvK/fC8L3IfGaOnZQnRyA=";
  };
}
