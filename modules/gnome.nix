{ modulesPath, config, lib, pkgs, ... }: {
  imports = [
    ./desktop_apps.nix
  ];

  services.xserver = {
    enable = true;
    displayManager.gdm.enable = true;
    desktopManager.gnome = {
      enable = true;
      extraGSettingsOverrides = ''
                [org.gnome.desktop.input-sources]
                sources=[('xkb', 'us'), ('xkb', 'de')]
        	[org.gnome.shell.world-clocks]
                locations=[<(uint32 2, <('Hamburg', 'EDDH', true, [(0.93607824966852793, 0.17453292519943295)], [(0.93462381444296339, 0.17453292519943295)])>)>]
        	[org.gnome.shell.weather]
        	locations=[<(uint32 2, <('Hamburg', 'EDDH', true, [(0.93607824966852793, 0.17453292519943295)], [(0.93462381444296339, 0.17453292519943295)])>)>]
                [org.gnome.desktop.wm.preferences]
                focus-mode='mouse'
      '';
    };
  };

  environment.systemPackages = with pkgs; [
    gnome.gnome-tweaks
    gnomeExtensions.appindicator
    gnomeExtensions.caffeine
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
    evince
    gnome-characters
    totem
    tali
    iagno
    hitori
    atomix
  ]);

  services.udev.packages = with pkgs; [ gnome.gnome-settings-daemon ];
  
  services.displayManager.enable = true;
}
