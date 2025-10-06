{lib, ...}: let
  inherit (lib) mkAliasOptionModule;
in {
  imports = [
    (
      mkAliasOptionModule
      ["homeDirectory"]
      ["home-manager" "users" "jules" "home" "homeDirectory"]
    )
  ];
}
