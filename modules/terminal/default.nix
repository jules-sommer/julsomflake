{
  lib,
  helpers,
  ...
}: let
  inherit (helpers) mkEnableOpt enabled disabled;
in {
  imports = [
    ./ghostty
    ./kitty
  ];

  options.local.terminal = lib.mkOption {
    type = lib.types.submodule {
      options = {
        kitty = mkEnableOpt "Kitty terminal emulator.";
        ghostty = mkEnableOpt "Ghostty terminal emulator.";
      };
    };
    default = {
      kitty = enabled;
      ghostty = disabled;
    };
    description = "Configuration of various terminal emulators.";
  };
}
