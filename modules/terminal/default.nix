{lib, ...}: let
  inherit (lib) mkEnableOpt enabled disabled mkOpt;
in {
  imports = lib.getModulesRecursive ./. {max-depth = 0;};

  options.local.terminal = lib.mkOption {
    type = lib.types.submodule {
      options = {
        default =
          mkOpt
          (lib.types.enum ["kitty" "ghostty"])
          "kitty"
          "The default terminal emulator to use. This determines things like $TERMINAL env vars, etc.";

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
