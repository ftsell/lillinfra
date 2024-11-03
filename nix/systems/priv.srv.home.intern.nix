{ modulesPath, config, lib, pkgs, home-manager, ... }: {
  imports = [
    ../modules/base_system.nix
    ../modules/hosting_guest.nix
    ../modules/user_ftsell.nix
  ];

  # boot config
  boot.supportedFilesystems.zfs = true;
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/1e6410b4-2756-4153-a210-df9ee4f12be4";
      fsType = "ext4";
    };
    "/boot" = {
      device = "/dev/disk/by-uuid/6A78-AB7F";
      fsType = "vfat";
      options = [ "fmask=0077" "dmask=0077" ];
    };
  };

  # network config
  networking.useDHCP = false;
  systemd.network = {
    enable = true;
    networks.enp1s0 = {
      matchConfig.Type = "ether";
      networkConfig.DHCP = "yes";
    };
  };

  # general hosting config
  virtualisation.podman = {
    enable = true;
    autoPrune.enable = true;
    defaultNetwork.settings.dns_enabled = true;
  };

  networking.firewall.allowedTCPPorts = [
    8000 # paperless web
    8384 # syncthing gui
  ];

  # syncthing service
  services.syncthing = {
    enable = true;
    dataDir = "/srv/data/encrypted/syncthing";
    settings.options.urAccepted = -1;
    guiAddress = "0.0.0.0:8384";
    openDefaultPorts = true;
    overrideFolders = false;
    overrideDevices = false;
  };

  # postgres service
  services.postgresql = {
    enable = true;
    ensureDatabases = [ "root" "ftsell" "paperless" ];
    ensureUsers = [
      {
        name = "ftsell";
        ensureDBOwnership = true;
        ensureClauses.superuser = true;
      }
      {
        name = "root";
        ensureDBOwnership = true;
        ensureClauses.superuser = true;
      }
      {
        name = "paperless";
        ensureDBOwnership = true;
      }
    ];
  };

  # paperless webserver
  virtualisation.oci-containers.containers."paperless-web" = {
    image = "ghcr.io/paperless-ngx/paperless-ngx";
    dependsOn = [ "paperless-broker" "paperless-gotenberg" "paperless-tika" ];
    volumes = [
      "/srv/data/encrypted/paperless/webserver/data:/usr/src/paperless/data"
      "/srv/data/encrypted/paperless/webserver/media:/usr/src/paperless/media"
      "/srv/data/encrypted/paperless/consume:/usr/src/paperless/consume"
      "/srv/data/encrypted/paperless/export:/usr/src/paperless/export"
    ];
    environment = {
      "PAPERLESS_URL" = "https://docs.home.lly.sh";
      "PAPERLESS_TRUSTED_PROXIES" = "192.168.20.102";
      "PAPERLESS_REDIS" = "redis://localhost:6379";
      "PAPERLESS_DBENGINE" = "postgresql";
      "PAPERLESS_DBHOST" = "localhost";
      "PAPERLESS_TIKA_ENABLED" = "1";
      "PAPERLESS_TIKA_GOTENBERG_ENDPOINT" = "http://localhost:3000";
      "PAPERLESS_TIKA_ENDPOINT" = "http://localhost:9998";
    };
    extraOptions = [ "--net=host" ];
  };

  # paperless redis broker
  virtualisation.oci-containers.containers."paperless-broker" = {
    image = "docker.io/library/redis:7";
    volumes = [
      "/srv/data/encrypted/paperless/redis:/data"
    ];
    extraOptions = [ "--net=host" ];
  };

  # paperless gotenberg
  virtualisation.oci-containers.containers."paperless-gotenberg" = {
    image = "docker.io/gotenberg/gotenberg:8.7";
    cmd = [
      "gotenberg"
      "--chromium-disable-javascript=true"
      "--chromium-allow-list=file:///tmp/.*"
    ];
    extraOptions = [ "--net=host" ];
  };

  # paperless tika
  virtualisation.oci-containers.containers."paperless-tika" = {
    image = "docker.io/apache/tika:latest";
    extraOptions = [ "--net=host" ];
  };

  # DO NOT CHANGE
  # this defines the first version of NixOS that was installed on the machine so that programs with non-migratable data files are kept compatible
  home-manager.users.ftsell.home.stateVersion = "24.05";
  system.stateVersion = "24.05";
  networking.hostId = "1a091689";
}
