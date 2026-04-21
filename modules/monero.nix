{lib, ...}: let
  inherit (lib) disabled';
in {
  services.monero = disabled' {
    prune = true;
    limits = {
      download = 3000;
      upload = 3000;
      threads = 2;
    };
  };
}
