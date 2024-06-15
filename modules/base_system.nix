{ modulesPath, config, lib, pkgs, ... }: {
  # settings for nix and nixos
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.nvidia.acceptLicense = true;
  nix.settings = {
    tarball-ttl = 60;
    trusted-users = [ "root" "@wheel" ];
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
    defaultLocale = lib.mkDefault "en_US.UTF-8";
    extraLocaleSettings = lib.genAttrs [
      "LC_CTYPE"
      "LC_NUMERIC"
      "LC_TIME"
      "LC_COLLATE"
      "LC_MONETARY"
      "LC_MESSAGES"
      "LC_PAPER"
      "LC_NAME"
      "LC_ADDRESS"
      "LC_TELEPHONE"
      "LC_MEASUREMENT"
      "LC_IDENTIFICATION"
    ]
      (key: "de_DE.UTF-8");
  };
  services.xserver.xkb.layout = lib.mkDefault "de";

  # vconsole
  console = {
    font = lib.mkDefault "${pkgs.terminus_font}/share/consolefonts/ter-u32n.psf.gz";
    packages = lib.mkDefault [ pkgs.terminus_font ];
    keyMap = lib.mkDefault "de";
    useXkbConfig = lib.mkDefault true;
  };

  # software settings
  home-manager.useGlobalPkgs = lib.mkDefault true;

  # additional apps
  environment.systemPackages = with pkgs; [
    vim
    git
    helix
    tig
    htop
  ];
}
