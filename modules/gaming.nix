{
  lib,
  pkgs,
  config,
  ...
}: let
  inherit (lib) mkEnableOpt enabled mkIf foldl' concat;
  cfg = config.local.gaming;
in {
  options.local.gaming = mkEnableOpt "Enable gaming applications.";

  config = mkIf cfg.enable {
    local.home.home.packages = with pkgs; [heroic];
  };
}

