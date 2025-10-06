{
  pkgs,
  lib,
  ...
}: let
  inherit (lib) enabled;
in {
  environment.systemPackages = with pkgs; [wl-clipboard];
  local = {
    home.services.cliphist = enabled;
    shells.settings.abbreviations = {
      yank = "wl-copy";
      put = "wl-paste";
    };
  };
}
