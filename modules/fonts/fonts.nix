{lib, ...}: let
  inherit (lib) types mkOption mkOpt';
  inherit (types) nullOr str submodule package number listOf;

  fontModule = submodule {
    options = {
      package = mkOption {
        type = package;
      };
      name = mkOption {
        type = str;
      };
    };
  };
in {
  options.local.ui.fonts = {
    packages = mkOpt' (listOf package) [];
    defaults = {
      monospace = mkOption {
        type = nullOr fontModule;
        default = null;
      };
      sans-serif = mkOption {
        type = nullOr fontModule;
        default = null;
      };
      serif = mkOption {
        type = nullOr fontModule;
        default = null;
      };
      emoji = mkOption {
        type = nullOr fontModule;
        default = null;
      };
    };

    sizes = {
      applications = mkOption {
        type = number;
        default = 12.0;
      };
      terminal = mkOption {
        type = number;
        default = 12.0;
      };
      desktop = mkOption {
        type = number;
        default = 12.0;
      };
      popups = mkOption {
        type = number;
        default = 12.0;
      };
    };
  };
}
