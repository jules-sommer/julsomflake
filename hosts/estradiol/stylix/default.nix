{
  helpers,
  pkgs,
  ...
}: let
  inherit (helpers) enabled' enabled disabled;
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
