{ modulesPath, config, lib, pkgs, home-manager, ... }: {
  sops.secrets = {
    "ftsell/kubeconfig.yml" = {
      owner = "ftsell";
      group = "nogroup";
      sopsFile = ../dotfiles/ftsell/kubectl/config.secret.yml;
      path = "/home/ftsell/.kube/config";
      format = "binary";
    };
  };

  environment.systemPackages = with pkgs; [
    ansible
    ansible-lint
    nodejs
    nodePackages.pnpm
    python3
    pipenv
    poetry
    uv
    sshfs
    kubectl
    krew
    kubernetes-helm
    pass
    sshuttle
    jetbrains.webstorm
    jetbrains.rust-rover
    jetbrains.pycharm-professional
    jetbrains.datagrip
    jetbrains.idea-ultimate
    rustup
    clang
    pkg-config
    pre-commit
    uucp
    openssl
    gleam
    erlang
    terraform
  ];

  programs.fish.shellInit = ''
    fish_add_path $HOME/.krew/bin
  '';
}
