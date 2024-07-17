{ modulesPath, config, lib, pkgs, home-manager, ... }: {
  home-manager.users.ftsell.programs.vscode = {
      enable = true;
      mutableExtensionsDir = false;
      extensions = with pkgs; [
        vscode-extensions.rust-lang.rust-analyzer
        vscode-extensions.alefragnani.project-manager
        vscode-extensions.jnoortheen.nix-ide
        vscode-extensions.vscode-icons-team.vscode-icons
        vscode-extensions.ms-python.python
        vscode-extensions.mkhl.direnv
        vscode-extensions.ms-azuretools.vscode-docker
        vscode-extensions.vadimcn.vscode-lldb
        vscode-extensions.elixir-lsp.vscode-elixir-ls
        vscode-extensions.jnoortheen.nix-ide
        vscode-extensions.charliermarsh.ruff
      ];
      userSettings = {
        "files.autoSave" = "afterDelay";
        "telemetry.telemetryLevel" = "crash";
        "workbench.colorTheme" = "Default Light+";
        "workbench.iconTheme" = "vscode-icons";
        "workbench.tree.indent" = 16;
        "workbench.startupEditor" = "none";
        "extensions.autoUpdate" = false;
        "update.mode" = "none";
        "explorer.confirmDragAndDrop" = false;
        "redhat.telemetry.enabled" = false;
        "editor.minimap.enabled" = false;
        "projectManager.git.baseFolders" = [
          "/home/ftsell/Projects"
        ];
        "typescript.updateImportsOnFileMove.enabled" = "always";
        "javascript.updateImportsOnFileMove.enabled" = "always";
        "vsicons.dontShowNewVersionMessage" = true;
        "yaml.format.printWidth" = 110;
        "ruff.format.args" = [
          "--line-length=110"
        ];
        "[python]" = {
            "editor.defaultFormatter" = "charliermarsh.ruff";
            "editor.formatOnSave" = true;
        };
      };
    };

  environment.systemPackages = with pkgs; [
    nodejs
    nodePackages.pnpm
    python3
    pipenv
    poetry
    uv
    sshfs
  ];
}
