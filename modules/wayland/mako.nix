{
  lib,
  pkgs,
  packages,
  ...
}: let
  inherit (lib) mkForce getExe enabled';
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

      on-notify = "exec ${getExe pkgs.mpv} ${pkgs.kdePackages.ocean-sound-theme}/share/sounds/ocean/stereo/message-highlight.oga";
      on-button-left = "exec ${getExe packages.focus-notification-source} $id";
    };

    # extraConfig = concatStringsSep "\n" [
    #   (readFile "${themes_rose-pine_mako}/theme/rose-pine.theme")
    # ];
  };
}
