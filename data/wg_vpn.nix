let 
  mkClient = ipSuffix: pub: {
    pub = pub;
    ownIps = [ "10.20.30.${ipSuffix}/32" "fc10:20:30::${ipSuffix}/128" ];
    routedIps = [];
  };
in {
  vpn-srv = {
    pub = "SRVfDEjWZCEcxynQoK1iibpzVeDN61ghTEQPps3pmSY=";
    ownIps = [ "10.20.30.1/32" "fc10:20:30::1/128" ];
    routedIps = [ "10.20.30.1/24" "fc10:20:30::1/64" ];
    endpoint = "vpn.ftsell.de:51820";
  };
  finnsLaptop = mkClient "101" "LAPcOludjQrjfza0M+XA+fuwxpVfmqRKjBawAxWDyDY=";
  finnsPhone = mkClient "102" "PHN5Srlsv3x7+ehWF4SPz0eezcYlm7c0pIU5jXYuYG4=";
  home-proxy = mkClient "103" "GTWotNqG3way+5NacVVs9bDwbLXplo/afSwZzU2XzkU=";
}