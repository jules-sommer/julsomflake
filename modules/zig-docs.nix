{
  pkgs,
  lib,
  ...
}: let
  inherit (lib) enabled';
in {
  services = {
    dnsmasq = enabled' {
      settings = {
        address = "/zigdocs.local/192.168.1.11";
      };
    };
  };

  systemd.user.services.zig_docs = {
    description = "Zig nightly docs server (user)";
    path = with pkgs; [fish];
    serviceConfig = {
      Restart = "always";
      RestartSec = "5s";
      ExecStart = "${pkgs.julespkgs.zig-docs}/bin/zig-docs";
      KillMode = "process";
    };
    wantedBy = ["default.target"];
  };
}
