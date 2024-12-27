{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf mkMerge;
  cfg = config.local.programs.kmail;
in
{
  options.local.programs.kmail = {
    enable = mkEnableOption "Enable KMail from kdePackages.";
  };

  config = {
    environment.systemPackages =
      with pkgs.kdePackages;
      (mkMerge [
        (mkIf cfg.enable [
          kmail
          kmail-account-wizard
          kmailtransport
          kdepim-addons # for addressbook and other plugins
        ])
      ]);
  };
}
