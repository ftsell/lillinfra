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
  mkNat = macAddress: ipv4: {
    _type = "natGuest";
    ipv4 = ipv4;
    macAddress = macAddress;
  };
in
rec {
  # additional IPs ordered from MyRoot:
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
    # nat guests
    vpn-srv = mkNat "52:54:00:8e:97:05" "10.0.0.101";
    nix-builder = mkNat "52:54:00:5e:35:24" "10.0.0.102";
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
