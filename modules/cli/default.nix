{
  lib,
  helpers,
  ...
}: let
  inherit (helpers) mkEnableOpt enabled;
  inherit (lib) mkOption types;
in {
  imports = [
    ./joshuto
    ./btop
  ];

  options.local.cli = mkOption {
    type = types.submodule {
      options = {
        joshuto = mkEnableOpt "Enable joshuto file-browser.";
        btop = mkEnableOpt "Enable btop TUI system monitor.";
      };
    };

    default = {
      joshuto = enabled;
      btop = enabled;
    };

    description = "Per-user toggles for misc. CLI programs/utils.";
  };
}
