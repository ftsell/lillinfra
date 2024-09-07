let
  mkExposed = macAddress: ipv4: {
    _type = "exposedGuest";
    ipv4 = ipv4;
    macAddress = macAddress;
  };
  mkRouted = macAddress: ipv4: {
    _type = "routedGuest";
    ipv4 = ipv4;
    macAddress = macAddress;
  };
  mkNat = macAddress: ipv4: portForwards: {
    _type = "natGuest";
    ipv4 = ipv4;
    macAddress = macAddress;
    portForwards = portForwards;
  };
in
rec {
  # hosting.srv.ftsell.de server
  #   - Main IPv4:       37.153.156.125
  #   - IPv4 Gateway:    37.153.156.1
  #   - Main IPv6:       2a10:9906:1002:0:125::125/64
  #   - Routed IPv6:     2a10:9906:1002:125::/64
  #   - IPv6 Gateway:    2a10:9906:1002::1
  # additional IPs ordered from MyRoot
  #   - 37.153.156.168 - 37.153.156.175
  # private subnet
  #    - 10.0.0.0/24
  guests = {
    # exposed guests
    rt-hosting = mkExposed "52:54:00:af:bc:45" "37.153.156.168";
    # routed guests
    main-srv = mkRouted "52:54:00:ba:63:25" "37.153.156.169";
    mail-srv = mkRouted "52:54:00:66:e2:38" "37.153.156.170";
    bene-server = mkRouted "52:54:00:13:f8:f9" "37.153.156.172";
    vieta-server = mkRouted "52:54:00:6d:0e:83" "37.153.156.173";
    polygon-server = mkRouted "52:54:00:f9:64:31" "37.153.156.174";
    timon-server = mkRouted "52:54:00:00:c9:09" "37.153.156.171";
    # nat guests
    vpn-srv = mkNat "52:54:00:8e:97:05" "10.0.0.101" [
      { proto = "udp"; src = 51820; dst = 51820; }
    ];
  };

  routedGuests = (
    builtins.filter (i: i._type == "routedGuest")
      (builtins.attrValues guests)
  );
  natGuests = (
    builtins.filter (i: i._type == "natGuest")
      (builtins.attrValues guests)
  );
}
