{lib, ...}: let
  inherit (lib) mkEnableOption mkEnableOpt;
in {
  options.local.gaming = {
    enable = mkEnableOption "gaming";
    steam = {
      enable = mkEnableOption "steam";
      proton = mkEnableOpt "proton";
    };
  };
}
