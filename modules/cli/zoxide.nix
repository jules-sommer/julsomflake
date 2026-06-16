{
  lib,
  pkgs,
  config,
  ...
}: let
  inherit (lib) enabled' defaultShellIntegrations foldl' recursiveUpdate;
in {
  environment.systemPackages = with pkgs; [zoxide];
  local = {
    shells.aliases = {
      cd = "__zoxide_z";
      cdi = "__zoxide_zi"; # cd with zoxide interactively
      zd = "zoxide"; # edit the zoxide database
    };
    home.programs.zoxide = enabled' (foldl' recursiveUpdate {} [
      defaultShellIntegrations
      {
        options = ["--no-cmd"];
      }
    ]);
  };
  programs.zoxide =
    {
      enable = true;
      flags = config.home.programs.zoxide.options;
    }
    // defaultShellIntegrations;
}
