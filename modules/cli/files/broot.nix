{
  lib,
  pkgs,
  ...
}: let
  inherit (lib) enableShellIntegrations enabled' foldl' recursiveUpdate enabled getExe;
in {
  local = {
    shells.aliases = {
      br = "broot -hips";
      brw = "broot -whips";
    };

    home.programs.broot = let
      tar = getExe pkgs.gnutar;
      nvim = getExe pkgs.neovim;
    in (foldl' recursiveUpdate {} [
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
              execution = "${nvim} {file}";
            }
            {
              invocation = "list";
              shortcut = "ls";
              execution = "${tar} -tvf {file-name}";
              from_shell = true;
            }
            {
              invocation = "archive_named {name}";
              shortcut = "arn";
              execution = "tar czf {parent}/{name}.tar.gz {file-name}";
              from_shell = true;
            }
            {
              invocation = "long_archive";
              shortcut = "lar";
              execution = "tar -I 'xz -9e' -cf {file-name}.tar.xz {file-name}";
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
    ]);
  };
}
