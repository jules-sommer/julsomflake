{
  lib,
  pkgs,
  ...
}: let
  inherit (lib) enabled' enabled;
in {
  services.rustdesk-server = enabled' {
    signal = enabled' {
      relayHosts = ["0.0.0.0"];
      extraArgs = [
        "-k"
        "julietest"
      ];
    };
    relay = enabled' {
      extraArgs = [
        "-k"
        "julietest"
      ];
    };
    openFirewall = true;
  };

  local.home.home.packages = with pkgs; [rustdesk];
}
