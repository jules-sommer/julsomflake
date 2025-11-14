{
  lib,
  pkgs,
  packages,
  ...
}: let
  inherit (lib) mkForce concatStringsSep getBinary enabled';
  inherit (builtins) readFile;
  inherit (packages) themes_rose-pine_mako;

  focus-notification-source-script = pkgs.writeShellScriptBin "focus-notification-source" (readFile ./mako/focus-notification-source.sh);
in {
  environment.systemPackages = with pkgs; [libnotify];
  local.home.services.mako = enabled' {
    settings = {
      font = mkForce "JetBrainsMono Nerd Font 12";
      icons = true;
      markup = true;
      anchor = "top-right";
      margin = 15;
      height = 125;
      width = 350;
      actions = true;
      border-radius = 4;

      on-notify = "exec ${pkgs.mpv}/bin/mpv ${pkgs.kdePackages.ocean-sound-theme}/share/sounds/ocean/stereo/message-highlight.oga";
      # on-button-left = "exec ${getBinary focus-notification-source-script} $id";
    };

    extraConfig = concatStringsSep "\n" [
      (readFile "${themes_rose-pine_mako}/theme/rose-pine.theme")
      "on-notify=exec mpv ${pkgs.kdePackages.ocean-sound-theme}share/sounds/ocean/stereo/message-highlight.oga"
    ];
  };
}
