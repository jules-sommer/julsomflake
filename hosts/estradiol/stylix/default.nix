{
  helpers,
  pkgs,
  lib,
  ...
}: let
  inherit (helpers) enabled';
  inherit (lib) genAttrs;
in {
  stylix = enabled' {
    autoEnable = true;
    iconTheme = {
      dark = "breeze-dark";
      light = "breeze";
      package = pkgs.breeze-icons;
    };
  };
}
