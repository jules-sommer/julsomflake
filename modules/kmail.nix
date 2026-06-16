{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOpt optionals;
  cfg = config.local.programs.kmail;
in {
  options.local.programs.kmail = mkEnableOpt "kmail";
  config = {
    environment = {
      pathsToLink = ["/share"];
      systemPackages = optionals cfg.enable (with pkgs.kdePackages; [
        kmail
        kmail-account-wizard
        kmailtransport
        kdepim-addons # for addressbook and other plugins
        kdepim-runtime
        akonadi
        kwalletmanager
      ]);
    };
  };
}
