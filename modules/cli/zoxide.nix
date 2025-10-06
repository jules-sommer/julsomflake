{
  lib,
  pkgs,
  ...
}: let
  inherit (lib) enabled' enableShellIntegrations;
in {
  environment.systemPackages = with pkgs; [zoxide];
  local = {
    shells.aliases = {
      cd = "z";
      cdi = "zi"; # cd with zoxide interactively
      zd = "zoxide"; # edit the zoxide database
    };
    home.programs.zoxide =
      enabled' (enableShellIntegrations ["fish" "zsh" "bash"] true)
      // {
        options = ["--no-cmd"];
      };
  };
}
