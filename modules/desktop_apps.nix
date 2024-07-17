{ modulesPath, config, lib, pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    element-desktop
    telegram-desktop
    signal-desktop
    whatsapp-for-linux
    nextcloud-client
    keepassxc
    wl-clipboard
    thunderbird
    spotify
    drawio
  ];

  programs.firefox = {
    enable = true;
    policies = {
      DisableTelemetry = true;
      DisablePocket = true;
      NoDefaultBookmarks = true;
      PasswordManagerEnabled = false;
      ExtensionSettings = {
        "uBlock0@raymondhill.net" = {
          installation_mode = "normal_installed";
        };
        "CookieAutoDelete@kennydo.com" = {
          installation_mode = "normal_installed";
        };
        "keepassxc-browser@keepassxc.org" = {
          installation_mode = "normal_installed";
        };
        "idcac-pub@guus.ninja" = {
          installation_mode = "normal_installed";
        };
      };
    };
  };
}
