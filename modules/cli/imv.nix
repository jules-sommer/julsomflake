{lib, ...}: let
  inherit (lib) enabled';
in {
  local.home.programs.imv = enabled' {
    settings = {
      options = {
        background = "checks";
        scaling_mode = "shrink";
      };
      aliases = {
        x = "close";
        h = "pan -50 0";
        j = "pan 0 -50";
        k = "pan 0 50";
        l = "pan 50 0";
      };
    };
  };
}
