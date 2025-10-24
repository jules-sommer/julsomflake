{lib, ...}: let
  inherit (lib) enabled' genAttrs;
in {
  programs.localsend = enabled' {
    openFirewall = true;
  };
}
