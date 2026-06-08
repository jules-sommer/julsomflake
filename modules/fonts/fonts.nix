{lib, ...}: let
  inherit (lib) types mkOption mkOpt' mkOpt mkEnableOption;
  inherit (types) nullOr str submodule package number listOf enum;

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
    antialias = mkEnableOption true;

    subpixel = mkOpt (nullOr (enum ["none" "rgb" "bgr" "vertical-rgb" "vertical-bgr"])) "none" "Ordering of subpixels for your display. Vast majority of display's are \"rgb\" when in their normal orientation.";

    hinting = {
      enable = mkEnableOption false;
      style = mkOpt (nullOr (enum ["none" "slight" "medium" "full"])) "none" "Hinting style is the amount of font reshaping done to line up to the grid.";
    };

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
