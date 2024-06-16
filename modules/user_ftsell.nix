{ modulesPath, config, lib, pkgs, home-manager, ... }: {
  programs.fish.enable = true;

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

  home-manager.users.ftsell = {
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
      includes =
        let
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
        "bits" = home-manager.lib.hm.dag.entryBefore [ "rzssh1.informatik.uni-hamburg.de" ] {
          user = "bits";
          hostname = "www2.informatik.uni-hamburg.de";
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
        "fs5.informatik.uni-hamburg.de" = home-manager.lib.hm.dag.entryBefore [ "fs4.informatik.uni-hamburg.de" ] {
          user = "finn";
          proxyJump = "fs4.informatik.uni-hamburg.de";
        };
        "fs6.informatik.uni-hamburg.de" = home-manager.lib.hm.dag.entryBefore [ "rzssh1.informatik.uni-hamburg.de" ] {
          user = "finn";
          proxyJump = "rzssh1.informatik.uni-hamburg.de";
        };
        "fs7.informatik.uni-hamburg.de" = home-manager.lib.hm.dag.entryBefore [ "rzssh1.informatik.uni-hamburg.de" ] {
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
    programs.fish = {
      enable = true;
      shellAbbrs = {
        "ga" = "git add";
        "gst" = "git status";
        "gsw" = "git switch";
        "gl" = "git pull";
        "gp" = "git push";
        "gc" = "git commit";
      };
    };
  };
}
