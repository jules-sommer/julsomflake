{
  lib,
  utils,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkIf getExe;
  inherit (utils) escapeSystemdExecArgs;

  cfg = config.services.filebrowser-quantum;
  format = pkgs.formats.yaml {};
in {
  config = mkIf cfg.enable {
    systemd.services.filebrowser-quantum = {
      description = "FileBrowser Quantum";
      after = ["network.target"];
      wantedBy = ["multi-user.target"];

      serviceConfig = {
        ExecStart = escapeSystemdExecArgs [
          (getExe cfg.package)
          "-c"
          (format.generate "config.yaml" cfg.settings)
        ];

        EnvironmentFile = mkIf (cfg.environmentFile != null) cfg.environmentFile;

        User = cfg.user;
        Group = cfg.group;
        UMask = "0077";

        StateDirectory = [
          "filebrowser-quantum"
          "filebrowser-quantum/data"
        ];
        CacheDirectory = "filebrowser-quantum";
        WorkingDirectory = "/var/lib/filebrowser-quantum";

        ReadWritePaths = map (source: "-${source.path}") cfg.settings.server.sources;

        AmbientCapabilities = mkIf (cfg.settings.server.port < 1024) ["CAP_NET_BIND_SERVICE"];
        CapabilityBoundingSet = mkIf (cfg.settings.server.port < 1024) ["CAP_NET_BIND_SERVICE"];

        NoNewPrivileges = true;
        PrivateDevices = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        ProtectKernelTunables = true;
        ProtectKernelModules = true;
        ProtectControlGroups = true;
        LockPersonality = true;
        RestrictAddressFamilies = [
          "AF_UNIX"
          "AF_INET"
          "AF_INET6"
        ];
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        DevicePolicy = "closed";
      };
    };

    users.users = mkIf (cfg.user == "filebrowser-quantum") {
      filebrowser-quantum = {
        inherit (cfg) group;
        isSystemUser = true;
      };
    };

    users.groups = mkIf (cfg.group == "filebrowser-quantum") {
      filebrowser-quantum = {};
    };

    networking.firewall.allowedTCPPorts = mkIf cfg.openFirewall [cfg.settings.server.port];
  };
}
