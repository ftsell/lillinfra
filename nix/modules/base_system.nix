{
  modulesPath,
  config,
  lib,
  pkgs,
  ...
}:
{
  # settings for nix and nixos
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.nvidia.acceptLicense = true;
  nix.settings = {
    tarball-ttl = 60;
    trusted-users = [
      "root"
      "@wheel"
    ];
    experimental-features = [
      "nix-command"
      "flakes"
      "repl-flake"
    ];
  };
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  # locale settings
  time.timeZone = lib.mkDefault "Europe/Berlin";
  i18n = {
    # https://man.archlinux.org/man/locale.7
    defaultLocale = lib.mkDefault "en_US.UTF-8";
    extraLocaleSettings = lib.genAttrs [
      "LC_CTYPE"
      "LC_NUMERIC"
      "LC_TIME"
      "LC_COLLATE"
      "LC_MONETARY"
      "LC_PAPER"
      "LC_NAME"
      "LC_ADDRESS"
      "LC_TELEPHONE"
      "LC_MEASUREMENT"
      "LC_IDENTIFICATION"
    ] (key: "de_DE.UTF-8");
  };
  services.xserver.xkb.layout = lib.mkDefault "de";

  # vconsole
  console = {
    font = lib.mkDefault "${pkgs.terminus_font}/share/consolefonts/ter-u16n.psf.gz";
    packages = lib.mkDefault [ pkgs.terminus_font ];
    keyMap = lib.mkDefault "de";
    useXkbConfig = lib.mkDefault true;
  };

  # software settings
  home-manager.useGlobalPkgs = lib.mkDefault true;
  documentation.man.generateCaches = false;
  documentation.nixos.includeAllModules = true;
  documentation.nixos.options.warningsAreErrors = false;
  programs.command-not-found.enable = false;

  # derive sops key from ssh key if ssh is enable and configure host sepcific secrets
  sops.age.sshKeyPaths = lib.mkIf config.services.openssh.enable [ "/etc/ssh/ssh_host_ed25519_key" ];
  sops.defaultSopsFile = ../data/secrets + "/${config.networking.fqdnOrHostName}.yml";

  # additional apps
  environment.systemPackages = with pkgs; [
    git
    helix
    tig
    htop
    age
  ];
  environment.variables = {
    EDITOR = "hx";
    VISUAL = "hx";
  };
  environment.localBinInPath = true;
}
