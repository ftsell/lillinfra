{ modulesPath, config, lib, pkgs, ... }: {
  imports = [
    ./desktop_apps.nix
  ];

  services.xserver = {
    enable = true;
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
  };

  home-manager.users.ftsell.dconf = with lib.gvariant; {
    enable = true;
    settings = {
      "org/gnome/desktop/interface" = {
        enable-hot-corners = true;
        show-battery-percentage = true;
      };
      "org/gnome/desktop/media-handling" = {
        automount = false;
        automount-open = false;
      };
      "org/gnome/desktop/input-sources" = {
        sources = [ (mkTuple [ "xkb" "de" ]) (mkTuple [ "xkb" "de+neo" ]) ];
      };
      "org/gnome/mutter" = {
        edge-tiling = true;
        dynamic-workspaces = true;
      };
      "org/gnome/desktop/wm/preferences" = {
        button-layout = "appmenu:minimize,close";
        focus-mode = "mouse";
      };
    };
  };

  environment.systemPackages = with pkgs; [
    gnome.gnome-tweaks
    gnomeExtensions.appindicator
    gnomeExtensions.caffeine
    gnomeExtensions.vitals
  ];

  environment.gnome.excludePackages = (with pkgs; [
    gnome-photos
    gnome-tour
  ]) ++ (with pkgs.gnome; [
    cheese
    gnome-music
    gnome-terminal
    gnome-calendar
    epiphany
    geary
    gnome-characters
    totem
    tali
    iagno
    hitori
    atomix
  ]);

  services.udev.packages = with pkgs; [ gnome.gnome-settings-daemon ];

  services.displayManager.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };
  hardware.pulseaudio.enable = false;
}
