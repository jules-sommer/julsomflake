{
  lib,
  helpers,
  ...
}: let
  inherit (helpers) mkEnableOpt enabled;
  inherit (lib) mkOption types;
in {
  imports = [
    ./btop
    ./helix
    ./joshuto
    ./starship
  ];

  options.local.cli = mkOption {
    type = types.submodule {
      options = {
        joshuto = mkEnableOpt "Enable joshuto file-browser.";
        btop = mkEnableOpt "Enable btop TUI system monitor.";
        helix = mkEnableOpt "Enable helix text editor.";
        starship = mkEnableOpt "Enable starship shell prompt.";
      };
    };

    default = {
      joshuto = enabled;
      btop = enabled;
      helix = enabled;
      starship = enabled;
    };

    description = "Per-user toggles for misc. CLI programs/utils.";
  };
}
