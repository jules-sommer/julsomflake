{
  lib,
  packages,
  ...
}: let
  inherit (lib) enableShellIntegrations enabled';
in {
  local = {
    home.programs.eza =
      enabled' {
        colors = "auto";
        theme = "${packages.themes_eza}/themes/rose-pine.yml";
        git = true;
        icons = "auto";
      }
      // enableShellIntegrations ["bash" "fish" "zsh"] true
      // enableShellIntegrations ["ion" "nushell"] false;

    shells.aliases = {
      ls = "eza --icons=always --hyperlink --color=always --color-scale=all --git-ignore";
      lst = "eza --icons=always --hyperlink --color=always --color-scale=all --git-ignore --tree";
      lsa = "eza --icons=always --hyperlink --color=always --color-scale=all --git-ignore --tree -la";
    };
  };
}
