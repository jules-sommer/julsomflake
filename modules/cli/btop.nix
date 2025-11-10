{
  helpers,
  config,
  ...
}: let
  inherit (helpers) enabledPred;
  hasBtop = config.local.cli.btop.enable;
in {
  local.home.programs.btop = enabledPred hasBtop {
    settings = {
      vim_keys = true;
      proc_gradient = false;
      proc_sorting = "cpu direct";
      update_ms = 750;
    };
  };
}
