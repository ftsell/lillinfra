{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.custom.backup;
in
{
  imports = [ ];

  options = {
    custom.backup.rsync-net = {
      enable = mkEnableOption "backups to rsync.net";
      passwordFilePath = mkOption {
        type = types.str;
        description = "The path inside the hosts secret data file which contains the encryption passphrase of the borg archive";
        default = "backup/rsync-net/encryption-passphrase";
      };
      sshKeyPath = mkOption {
        type = types.str;
        description = "The path inside the hosts secret data file which holds the ssh private key that is used to connect to rsync.net";
        default = "backup/rsync-net/ssh-key";
      };
      sshUser = mkOption {
        type = types.str;
        default = "zh4525";
      };
      sshHost = mkOption {
        type = types.str;
        default = "zh4525.rsync.net";
      };
      sshPath = mkOption {
        description = "The path on rsync.net which holds the borg repository to which this host is backed up";
        type = types.str;
        default = "./borgbackup";
      };
      sourceDirectories = mkOption {
        type = types.listOf types.path;
        default = [
          "/home/ftsell"
        ];
      };
    };
  };

  config = mkIf cfg.rsync-net.enable {
    services.borgmatic.enable = true;
    services.borgmatic.configurations."rsync-net" = {
      source_directories = cfg.rsync-net.sourceDirectories;
      repositories = [
        {
          label = "rsync.net";
          path = "ssh://${cfg.rsync-net.sshUser}@${cfg.rsync-net.sshHost}/${cfg.rsync-net.sshPath}";
        }
      ];
      one_file_system = true;
      exclude_patterns = [
        "~/.rustup/toolchains"
        "~/.vim/undodir"
        "~/.local/share/containers"
        "~/.local/share/virtualenvs"
        "~/.local/share/JetBrains/Toolbox/apps/"
        "~/Downloads"
        "~/Games"
        "~/.cache"
        "~/.local/share/Trash"
        "~/.local/share/pnpm/store"
        "~/.npm"
        "**/node_modules/"
        "**/cache/"
        "**/Cache/"
        "~/Projects/**/target/"
      ];
      encryption_passcommand = "${pkgs.coreutils}/bin/cat /run/secrets/${cfg.rsync-net.passwordFilePath}";
      archive_name_format = "{hostname}--user_{user}--{now}";
      relocated_repo_access_is_ok = true;
      keep_hourly = 48;
      keep_daily = 7;
      keep_weekly = 8;
      ssh_command = "ssh -i /run/secrets/${cfg.rsync-net.sshKeyPath} -o StrictHostKeyChecking=no";
      #extra_borg_options.create = "--info";
    };

    systemd.timers.borgmatic.timerConfig.OnCalendar = "hourly";

    sops.secrets = {
      ${cfg.rsync-net.sshKeyPath} = { 
        mode = "0400";
      };
      ${cfg.rsync-net.passwordFilePath} = { 
        mode = "0400";
      };
    };
  };
}
