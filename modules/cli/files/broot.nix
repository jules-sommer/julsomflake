{
  lib,
  pkgs,
  ...
}: let
  inherit (lib) enableShellIntegrations enabled' foldl' recursiveUpdate enabled;
in {
  local = {
    shells.aliases = {
      br = "broot -hips";
      brw = "broot -whips";
    };

    home.programs.broot = foldl' recursiveUpdate {} [
      enabled
      (enableShellIntegrations ["bash" "fish" "zsh"] true)
      {
        settings = {
          modal = true;
          verbs = [
            {
              invocation = "nvim";
              shortcut = "e";
              key = "ctrl-e";
              execution = "${pkgs.neovim}/bin/nvim {file}";
            }
            {
              invocation = "archive_named {name}";
              shortcut = "arn";
              execution = "tar czf {parent}/{name}.tar.gz {file-name}";
              from_shell = true;
            }
            {
              invocation = "archive";
              shortcut = "ar";
              execution = "tar czf {file-name}.tar.gz {file-name}";
              from_shell = true;
            }
            {
              invocation = "bat";
              shortcut = "b";
              key = "ctrl-b";
              execution = "${pkgs.bat}/bin/bat {file}";
            }
            {
              invocation = "rsync_to {destination}";
              execution = "${pkgs.rsync}/bin/rsync -avz --progress {file} {destination}";
              from_shell = true;
            }
            {
              invocation = "rsync_here";
              execution = "${pkgs.rsync}/bin/rsync -avz --progress {file} {directory}/";
              from_shell = true;
            }
            {
              invocation = "restic_backup {repo}";
              execution = "${pkgs.restic}/bin/restic backup {file}";
              from_shell = true;
            }
            {
              invocation = "restic_backup_default";
              shortcut = "bak";
              execution = "${pkgs.restic}/bin/restic backup {file}";
              from_shell = true;
            }
          ];
        };
      }
    ];
  };
}
