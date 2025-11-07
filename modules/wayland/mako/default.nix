{
  helpers,
  lib,
  pkgs,
  packages,
  ...
}: let
  inherit (lib) mkForce concatStringsSep;
  inherit (builtins) readFile;
  inherit (helpers) enabled';
  inherit (packages) themes_rose-pine_mako;
in {
  local.home.services.mako = enabled' {
    settings = {
      font = mkForce "JetBrainsMono Nerd Font 12";
      icons = true;
      markup = true;
      anchor = "top-right";
      margin = 15;
      height = 125;
      width = 350;
      on-notify = "exec ${pkgs.mpv}/bin/mpv ${pkgs.kdePackages.ocean-sound-theme}/share/sounds/ocean/stereo/message-highlight.oga";
      actions = true;
      border-radius = 4;
    };
    extraConfig = concatStringsSep "\n" [
      (readFile "${themes_rose-pine_mako}/theme/rose-pine.theme")
      "on-notify=exec mpv ${pkgs.kdePackages.ocean-sound-theme}share/sounds/ocean/stereo/message-highlight.oga"
    ];
  };
}
