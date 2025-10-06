{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOpt mkIf;
  cfg = config.local.programs.kmail;
in {
  options.local.programs.kmail = mkEnableOpt "Enable KMail from kdePackages.";

  config.environment.systemPackages = with pkgs.kdePackages; (mkIf cfg.enable [
    kmail
    kmail-account-wizard
    kmailtransport
    kdepim-addons # for addressbook and other plugins
  ]);
}
