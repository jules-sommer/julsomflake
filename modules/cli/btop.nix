{
  lib,
  config,
  ...
}: let
  inherit (lib) mkEnableOpt mkIf enabled';
  hasBtop = config.local.cli.btop.enable;
in {
  options.local.cli.btop = mkEnableOpt "Whether to enable btop process monitor.";
  config.local.home.programs.btop = mkIf hasBtop (enabled' {
    settings = {
      vim_keys = true;
      proc_gradient = false;
      proc_sorting = "cpu direct";
      update_ms = 1000;
    };
  });
}
