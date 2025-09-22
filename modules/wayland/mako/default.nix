{
  helpers,
  lib,
  packages,
  ...
}: let
  inherit (lib) mkDefault;
  inherit (helpers) enabled';
  inherit (packages) rose-pine_mako;
in {
  local.home.services.mako = enabled' {
    settings = {
      font = mkDefault "JetBrainsMono 12";
      icons = true;
      markup = true;
      anchor = "top-right";
      margin = 10;
    };
    extraConfig =
      builtins.readFile
      "${rose-pine_mako}/theme/rose-pine.theme";
  };
}
