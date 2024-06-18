let
  mkExposed = macAddress: ipv4: {
    _type = "exposedGuest";
    ipv4 = ipv4;
    macAddress = macAddress;
  };
  mkGuest = macAddress: ipv4: {
    _type = "routedGuest";
    ipv4 = ipv4;
    macAddress = macAddress;
  };
in
rec {
  subnet4 = "37.153.156.168 - 37.153.156.175";
  guests = {
    rt-hosting = mkExposed "52:54:00:af:bc:45" "37.153.156.168";
    main-srv = mkGuest "52:54:00:ba:63:25" "37.153.156.169";
    mail-srv = mkGuest "52:54:00:66:e2:38" "37.153.156.170";
    vpn-srv = mkGuest "52:54:00:8e:97:05" "37.153.156.171";
    bene-server = mkGuest "52:54:00:13:f8:f9" "37.153.156.172";
  };
  routedGuests = (
    builtins.filter (i: i._type == "routedGuest")
      (builtins.attrValues guests)
  );
}
