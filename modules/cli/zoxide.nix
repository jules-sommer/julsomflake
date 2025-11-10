{
  lib,
  pkgs,
  ...
}: let
  inherit (lib) enabled' enableShellIntegrations foldl' recursiveUpdate;
in {
  environment.systemPackages = with pkgs; [zoxide];
  local = {
    shells.aliases = {
      cd = "__zoxide_z";
      cdi = "__zoxide_zi"; # cd with zoxide interactively
      zd = "zoxide"; # edit the zoxide database
    };
    home.programs.zoxide = enabled' (foldl' recursiveUpdate {} [
      (enableShellIntegrations ["fish" "zsh" "bash"] true)
      {
        options = ["--no-cmd"];
      }
    ]);
  };
}
