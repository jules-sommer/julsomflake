{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOpt mkIf enabled';
  hasBtop = config.local.cli.btop.enable;
in {
  options.local.cli.btop = mkEnableOpt "btop";
  config = {
    environment.systemPackages = with pkgs; [btop];
    local.home.programs.btop = mkIf hasBtop (enabled' {
      settings = {
        vim_keys = true;
        proc_gradient = false;
        proc_sorting = "cpu direct";
        update_ms = 1000;
      };
    });
  };
}
