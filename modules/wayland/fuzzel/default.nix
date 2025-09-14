{
  pkgs,
  helpers,
  ...
}: let
  inherit (helpers) enabled';
in {
  local.home.programs.fuzzel = enabled' {
    settings = {
      main = {
        terminal = "${pkgs.kitty}/bin/kitty";
        layer = "overlay";
      };
    };
  };
}
