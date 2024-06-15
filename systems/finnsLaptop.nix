{ modulesPath, config, lib, pkgs, home-manager, ... }: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];


  # nixos-generate output
  boot.initrd.availableKernelModules = [ "xhci_pci" "nvme" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "UUID=5e4c1696-760d-4823-89c8-64f4345f081a";
      fsType = "bcachefs";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/5C6D-BE54";
      fsType = "vfat";
      options = [ "fmask=0077" "dmask=0077" ];
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/cfee5359-def6-43f6-9e0e-e461a41212c6"; }
    ];

  hardware.cpu.intel.updateMicrocode = config.hardware.enableRedistributableFirmware;
  programs.fish.enable = true;
  nixpkgs.hostPlatform = "x86_64-linux";
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.nvidia.acceptLicense = true;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot = {
    enable = true;
    configurationLimit = 10;
    editor = false;
  };
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = [ "bcachefs" ]; 

  # user config
  networking.hostName = "finnsLaptop";
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
    "repl-flake"
  ];
  environment.systemPackages = with pkgs; [
    vim
    git
    helix
    keepassxc
    tig
    vscode
    nextcloud-client
    htop
    gnome.gnome-tweaks
    gnomeExtensions.appindicator
    gnomeExtensions.caffeine
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
  networking.wireless.enable = false;
  networking.wireless.iwd.enable = false;
  time.timeZone = "Europe/Berlin";
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "${pkgs.terminus_font}/share/consolefonts/ter-u32n.psf.gz";
    packages = [ pkgs.terminus_font ];
    keyMap = lib.mkForce "de";
    useXkbConfig = true; # use xkb.options in tty.
  };
  users.users.ftsell = {
    createHome = true;
    extraGroups = [ "wheel" "networkmanager" ];
    home = "/home/ftsell";
    shell = pkgs.fish;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPzGnNKyn6jmVxig4SRnTBfpi6okPU2aOHPwFnAPTxJm ftsell@ftsell.de"
    ];
    hashedPassword = "$y$j9T$x55BKHAikhaUeAPN6GsCa/$uig7LwmWeodvbBKKMmlO7k/UbtU.Za6RuS.QI5O5ag9";
    isNormalUser = true;
  };
  home-manager.useGlobalPkgs = true;
  home-manager.users.ftsell = {
    home.stateVersion = "24.05";
    home.preferXdgDirectories = true;
    xdg.configFile = {
      "helix/config.toml" = {
        text = ''
          theme = "base16_default_light"

          [editor]
          bufferline = "always"
        '';
      };
      "wezterm/wezterm,lua" = {
        text = ''
          local wezterm = require "wezterm"
          local config = wezterm.config_builder()

          config.color_scheme = "Alabaster"
          config.use_fancy_tab_bar = true
          config.keys = {
            {
              key = "E",
              mods = "CTRL",
              action = wezterm.action.SplitPane { direction = "Right" },
            },
            {
              key = "O",
              mods = "CTRL",
              action = wezterm.action.SplitPane { direction = "Down" }
            },
            {
              key = "RightArrow",
              mods = "ALT",
              action = wezterm.action.ActivatePaneDirection "Right",
            },
            {
              key = "LeftArrow",
              mods = "ALT",
              action = wezterm.action.ActivatePaneDirection "Left",
            },
            {
              key = "UpArrow",
              mods = "ALT",
              action = wezterm.action.ActivatePaneDirection "Up",
            },
            {
              key = "DownArrow",
              mods = "ALT",
              action = wezterm.action.ActivatePaneDirection "Down",
            },
          }

          return config
        '';
      };
    };
    programs.git = {
      enable = true;
      diff-so-fancy.enable = true;
      diff-so-fancy.rulerWidth = 110;
      ignores = [
        "**/.*.swp"
        "**/__pycache__"
        ".idea"
      ];
      aliases = {
        # git auf deutsch
        eroeffne = "init";
        machnach = "clone";
      	zieh = "pull";
      	fueghinzu = "add";
      	drueck = "push";
      	pfusch = "push";
      	zweig = "branch";
      	verzweige = "branch";
      	uebergib = "commit";
      	erde = "rebase";
      	unterscheide = "diff";
      	vereinige = "merge";
      	bunkere = "stash";
      	markiere = "tag";
      	nimm = "checkout";
      	tagebuch = "log";
      	zustand = "status";
      };
      extraConfig = {
        user = {
          name = "ftsell";
          email = "dev@ftsell.de";
        };
        core = {
          autocrlf = "input";
          fscache = true;
        };
        pull = {
          rebase = true;
        };
        color = {
          ui = "auto";
        };
        init = {
          defaultBranch = true;
        };
        push = {
          autoSetupRemote = true;
        };
      };
      includes = let
        workConfig = {
            user = {
              name = "ftsell";
              email = "f.sell@vivaconagua.org";
            };
        };
        cccConfig = {
          user = {
            name = "finn";
            email = "ccc@ftsell.de";
          };
        };
        in
        [
          {
            condition = "hasconfig:remote.origin.url:git@github.com/viva-con-agua/**";
            contents = workConfig;
          }
          {
            condition = "hasconfig:remote.origin.url:https://github.com/viva-con-agua/**";
            contents = workConfig;
          }
          {
            condition = "hasconfig:remote.origin.url:forgejo@git.hamburg.ccc.de:*/**";
            contents = cccConfig;
          }
          {
            condition = "hasconfig:remote.origin.url:https://git.hamburg.ccc.de/**";
            contents = cccConfig;
          }
        ];
    };
    programs.ssh = {
      enable = true;
      matchBlocks = {
        # Private Hosts
        "nas.vpn.private" = {
          user = "ftsell";
        };
        "proxy.home.private" = {
          user = "ftsell";
        };
        "server.home.private" = {
          user = "ftsell";
        };
        "raspi5.home.private" = {
          user = "ftsell";
        };
        # Uni
        "rzssh1.informatik.uni-hamburg.de" = {
          user = "7sell";
        };
        "rzssh2.informatik.uni-hamburg.de" = {
          user = "7sell";
        };
        "bits" = home-manager.lib.hm.dag.entryBefore ["rzssh1.informatik.uni-hamburg.de"] {
          user = "bits";
          hostname= "www2.informatik.uni-hamburg.de";
          proxyJump = "bits@rzssh1.informatik.uni-hamburg.de";
        };
        "netsec-teaching" = {
          hostname = "195.37.209.19";
          user = "teaching";
        };
        # Server-AG
        "fs4.informatik.uni-hamburg.de" = {
          user = "finn";
        };
        "fs5.informatik.uni-hamburg.de" = home-manager.lib.hm.dag.entryBefore ["fs4.informatik.uni-hamburg.de"] {
          user = "finn";
          proxyJump = "fs4.informatik.uni-hamburg.de";
        };
        "fs6.informatik.uni-hamburg.de" = home-manager.lib.hm.dag.entryBefore ["rzssh1.informatik.uni-hamburg.de"] {
          user = "finn";
          proxyJump = "rzssh1.informatik.uni-hamburg.de";
        };
        "fs7.informatik.uni-hamburg.de" = home-manager.lib.hm.dag.entryBefore ["rzssh1.informatik.uni-hamburg.de"] {
          user = "finn";
          proxyJump = "rzssh1.informatik.uni-hamburg.de";
        };
        "monitoring.mafiasi.de" = {
          user = "finn";
        };
        # Viva con Agua
        "vca-cluster1" = {
          hostname = "cluster1.srv.vivaconagua.org";
          user = "ftsell";
        };
        "vca-pool" = {
          hostname = "pool.srv.vivaconagua.org";
          user = "ftsell";
        };
        "vca-live" = {
          hostname = "live.srv.vivaconagua.org";
          user = "ftsell";
        };
        "vca-backend" = {
          hostname = "backend.srv.vivaconagua.org";
          user = "ftsell";
        };
        "vca-prod" = {
          hostname = "production.srv.vivaconagua.org";
          user = "ftsell";
        };
        "vca-monitoring" = {
          hostname = "monitoring.srv.vivaconagua.org";
          user = "ftsell";
        };
        "vca-bi" = {
          hostname = "bi.srv.vivaconagua.org";
          user = "fsell";
        };
      };
    };
  };

  # Gnome Desktop settings
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
    videoDrivers = [ "nvidia" ];
  };
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
  hardware.opengl = {
    enable = true;
    driSupport = true;
  };
  hardware.nvidia = {
    modesetting.enable = true;
    open = false;
    nvidiaSettings = false;
    prime = {
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };
    };
  };

  # DO NOT CHANGE
  # this defines the first version of NixOS that was installed on the machine so that programs with non-migratable data files are kept compatible
  system.stateVersion = "24.05";
}
