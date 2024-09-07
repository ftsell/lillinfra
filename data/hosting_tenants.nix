{ pkgs ? import <nixpkgs> { } }:
let
  PRIV_ADDR_PREFIX = "10.0.";
  INTERN_DOMAIN_SUFFIX = "myroot.intern";

  mkDhcpReservation = hw-address: ip-address: { inherit hw-address ip-address; };

  mkDhcp4Config = subnet: pool-start: pool-end: router: {
    _type = "dhcp4-config";
    pool = "${pool-start} - ${pool-end}";
    inherit subnet router;
  };

  mkTenant = id: name: ip6-prefix: dhcp4: vms: {
    _type = "tenant";
    inherit id name ip6-prefix dhcp4 vms;
  };

  mkGuestVm = interfaces: {
    _type = "guest-vm-definition";
    inherit interfaces;
  };

  mkVmInterface = dns: hw-addr: ip-addr: {
    _type = "vm-interface";
    is-intern = pkgs.lib.strings.hasPrefix PRIV_ADDR_PREFIX ip-addr;
    inherit dns hw-addr ip-addr;
  };

in
rec {
  tenants = [
    (mkTenant
      10
      "finn"
      "2a10:9902:111:10::/64"
      (mkDhcp4Config "37.153.156.169/30" "37.153.156.169" "37.153.156.170" "10.0.10.2")
      [
        (mkGuestVm [
          (mkVmInterface "gtw.srv.ftsell.de" "52:54:00:43:ff:c6" "37.153.156.169")
          (mkVmInterface "gtw.finn.myroot.intern" "52:54:00:8c:88:66" "10.0.10.2")
        ])
        (mkGuestVm [
          (mkVmInterface "mail.srv.ftsell.de" "52:54:00:66:e2:38" "37.153.156.170")
          (mkVmInterface "mail.finn.myroot.intern" "52:54:00:7d:ff:7f" "10.0.10.12")
        ])
        (mkGuestVm [
          (mkVmInterface "main.finn.myroot.intern" "52:54:00:ba:63:25" "10.0.10.10")
        ])
        (mkGuestVm [
          (mkVmInterface "vpn.finn.myroot.intern" "52:54:00:8e:97:05" "10.0.10.11")
        ])
        (mkGuestVm [
          (mkVmInterface "monitoring.finn.myroot.intern" "52:54:00:00:47:69" "10.0.10.13")
        ])
      ]
    )

    (mkTenant
      11
      "bene"
      "2a10:9902:111:11::/64"
      (mkDhcp4Config "37.153.156.172/32" "37.153.156.172" "37.153.156.172", "10.0.11.1")
      []
      )
  ];

  getTenant = name: (pkgs.lib.findFirst (i: i.name == name) null tenants);
  allVms = pkgs.lib.flatten (builtins.map (i-tenant: i-tenant.vms) tenants);
  allVmInterfaces = pkgs.lib.flatten (builtins.map (i-vm: i-vm.interfaces) allVms);
}
