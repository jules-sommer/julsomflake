{
  pkgs,
  lib,
  config,
  ...
}: let
  inherit (lib) enabled' mkEnableOpt mkIf;
  cfg = config.local.http.services.zig-docs;
in {
  options.local.http.services.zig-docs = mkEnableOpt "Enable local zig-docs http service.";

  config = mkIf cfg.enable {
    services = {
      dnsmasq = enabled' {
        settings = {
          address = ["/zigdocs.local/127.0.0.1:43741"];
        };
      };
    };

    systemd.user.services.zig_docs = {
      Unit = {
        Description = "Zig nightly docs server (user)";
      };
      Install = {
        WantedBy = ["default.target"];
      };
      Service = {
        Environment = with pkgs; [fish];
        ExecStart = "${pkgs.julespkgs.zig-docs}/bin/zig-docs";
        Restart = "always";
        RestartSec = "5s";
        KillMode = "process";
      };
    };
  };
}
