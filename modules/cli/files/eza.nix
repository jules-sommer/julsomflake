{
  lib,
  packages,
  ...
}: let
  inherit (lib) defaultShellIntegrations enabled';
in {
  local = {
    home.programs.eza =
      enabled' {
        colors = "auto";
        theme = "${packages.themes_eza}/themes/rose-pine.yml";
        git = true;
        icons = "auto";
        extraOptions = [
          "--group-directories-first"
          "--header"
          "--git-ignore"
          "--hyperlink"
        ];
      }
      // defaultShellIntegrations;

    shells.aliases = {
      ls = "eza";
      lst = "eza -T";
      lsa = "eza -la";
    };
  };
}
