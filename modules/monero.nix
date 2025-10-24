{lib, ...}: let
  inherit (lib) enabled';
in {
  services.monero =
    enabled' {
    };
}
