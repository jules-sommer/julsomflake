{lib, ...}: let
  inherit (lib) enabled';
in {
  services.monero = enabled' {
    prune = true;
    limits = {
      download = 3000;
      upload = 3000;
      threads = 2;
    };
  };
}
