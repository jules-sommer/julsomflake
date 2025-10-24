{lib, ...}: let
  inherit (lib) enabled';
in {
  local.home.programs.jq = enabled' {
    colors = {
      null = "1;30";
      false = "0;31";
      true = "0;32";
      numbers = "0;36";
      strings = "0;33";
      arrays = "1;35";
      objects = "1;37";
      objectKeys = "1;34";
    };
  };
}
