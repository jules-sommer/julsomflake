{
  lib,
  pkgs,
  config,
  ...
}: let
  inherit (lib) mkEnableOpt enabled' mkIf;
  cfg = config.local.bitwarden;
in {
  options.local.bitwarden =
    mkEnableOpt "bitwarden";

  config = mkIf cfg.enable {
    nixpkgs.config.permittedInsecurePackages = ["electron-39.8.10"];
    environment.systemPackages = with pkgs; [bitwarden-cli];
    local.home = {
      programs.rbw = enabled' {
        settings = {
          email = "jsomme@pm.me";
        };
      };
      home.packages = with pkgs; [
        bitwarden-desktop
        rofi-rbw-wayland
      ];
    };
  };
}
