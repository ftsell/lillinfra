#
# Definition of the networking topology of my WireGuard-VPN
#
# This module exposes an AttrSet keyed by a clients hostname
#

let
  mkPeer = endpoint: ownIpSuffix: routedIp4: routedIp6: pub: keepalive: isRouteReflector: {
    inherit endpoint routedIp4 routedIp6 pub keepalive isRouteReflector;
    ownIp4 = "10.20.30.${ownIpSuffix}/32";
    ownIp6 = "fc10:20:30::${ownIpSuffix}/128";
  };

  mkSimpleClient = ipSuffix: pubkey: (mkPeer null ipSuffix [ ] [ ] pubkey false false);
in
{
  peers = {
    # main vpn server
    "vpn.srv.myroot.intern" = mkPeer "vpn.ftsell.de:51820" "1" [ "10.20.30.0/24" ] [ "fc10:20:30::/64" ] "SRVfDEjWZCEcxynQoK1iibpzVeDN61ghTEQPps3pmSY=" false true;

    # simple clients
    "nas.srv.myroot.intern" = mkPeer "10.0.10.14:51820" "2" [] [] "NASFYFuG6XOw+S/0Bu5prkrGrT8t86fJcZdpIEBjynU=" false false;
    finnsLaptop = mkSimpleClient "101" "LAPcOludjQrjfza0M+XA+fuwxpVfmqRKjBawAxWDyDY=";
    finnsPhone = mkSimpleClient "102" "PHN5Srlsv3x7+ehWF4SPz0eezcYlm7c0pIU5jXYuYG4=";

    # complex clients
    "proxy.home.private" = mkPeer "home.ftsell.de:51820" "103" [ "192.168.20.0/24" ] [] "GTWotNqG3way+5NacVVs9bDwbLXplo/afSwZzU2XzkU=" false false;

    #home-proxy = mkSimplePeer null "103" true "GTWotNqG3way+5NacVVs9bDwbLXplo/afSwZzU2XzkU=";
    #finnsWorkstation = mkSimplePeer null "104" false "WOrk7yTwmWilfWrOhF2EpmMvK/fC8L3IfGaOnZQnRyA=";
    #nas = null mkSimplePeer "105" true "NASuIV3T8lYoE2VTnuu+GPqq8Pzh/NHTfL06puPZDTE=";
  };
}
