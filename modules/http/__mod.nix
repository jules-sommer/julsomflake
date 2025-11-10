{
  config,
  lib,
  ...
}: let
  cfg = config.local.http;
  inherit (lib) mkIf types enabled' listToAttrs mkMerge mapAttrsToList;
  inherit (types) str port bool submodule attrsOf anything lines nullOr;

  mkVirtualHost = name: service: {
    name = service.domain;
    value = {
      forceSSL = mkIf service.ssl true;
      enableACME = mkIf (service.ssl && service.acme.enable) true;
      sslCertificate = mkIf (service.ssl && !service.acme.enable) service.acme.certPath;
      sslCertificateKey = mkIf (service.ssl && !service.acme.enable) service.acme.keyPath;

      locations."/" =
        {
          proxyPass = "http://${service.listenAddress}:${toString service.port}";
          proxyWebsockets = service.websockets;
          extraConfig = ''
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            ${service.extraNginxConfig}
          '';
        }
        // service.extraLocations;

      extraConfig = service.extraVirtualHostConfig;
    };
  };

  mkDnsmasqAddress = name: service: "/${service.domain}/${service.resolveAddress}";

  mkSystemdService = name: service:
    mkIf service.systemd.enable {
      name = "${name}-http-service";
      value = {
        description = "HTTP service for ${service.domain}";
        wantedBy = ["multi-user.target"];
        after = ["network.target"];

        serviceConfig =
          {
            Type = service.systemd.type;
            ExecStart = service.systemd.execStart;
            ExecReload = mkIf (service.systemd.execReload != null) service.systemd.execReload;
            WorkingDirectory = mkIf (service.systemd.workingDirectory != null) service.systemd.workingDirectory;

            User = mkIf service.systemd.createSystemUser service.systemd.user;
            Group = mkIf service.systemd.createSystemUser service.systemd.group;

            StateDirectory = mkIf (service.systemd.stateDirectory != null) service.systemd.stateDirectory;
            StateDirectoryMode = service.systemd.stateDirectoryMode;

            DynamicUser = mkIf (!service.systemd.createSystemUser) service.systemd.dynamicUser;
            PrivateTmp = service.systemd.privateTmp;
            ProtectSystem = service.systemd.protectSystem;
            ProtectHome = service.systemd.protectHome;

            Restart = service.systemd.restart;
            RestartSec = service.systemd.restartSec;
          }
          // service.systemd.extraConfig;

        environment = service.systemd.environment;
      };
    };

  serviceType = submodule {
    options = {
      domain = lib.mkOption {
        type = str;
        description = "Domain name for the service";
      };

      port = lib.mkOption {
        type = port;
        description = "Port the service listens on";
      };

      listenAddress = lib.mkOption {
        type = str;
        default = "127.0.0.1";
        description = "Address the service listens on";
      };

      resolveAddress = lib.mkOption {
        type = str;
        default = config.networking.hostName;
        description = "IP address to resolve the domain to via dnsmasq";
      };

      ssl = lib.mkOption {
        type = bool;
        default = false;
        description = "Enable SSL for this service";
      };

      websockets = lib.mkOption {
        type = bool;
        default = true;
        description = "Enable websocket proxying";
      };

      acme = {
        enable = lib.mkOption {
          type = bool;
          default = false;
          description = "Use ACME for SSL certificates";
        };

        certPath = lib.mkOption {
          type = str;
          description = "Path to SSL certificate when not using ACME";
        };

        keyPath = lib.mkOption {
          type = str;
          description = "Path to SSL private key when not using ACME";
        };
      };

      extraNginxConfig = lib.mkOption {
        type = lines;
        default = "";
        description = "Extra nginx configuration for the location block";
      };

      extraVirtualHostConfig = lib.mkOption {
        type = lines;
        default = "";
        description = "Extra nginx configuration for the virtual host";
      };

      extraLocations = lib.mkOption {
        type = attrsOf (submodule {
          options = {
            proxyPass = lib.mkOption {
              type = nullOr str;
              default = null;
            };
            extraConfig = lib.mkOption {
              type = lines;
              default = "";
            };
          };
        });
        default = {};
        description = "Additional nginx location blocks";
      };

      systemd = {
        enable = lib.mkOption {
          type = bool;
          default = false;
          description = "Create a systemd service for this HTTP service";
        };

        createSystemUser = lib.mkOption {
          type = bool;
          default = false;
          description = "Create a system user for the service";
        };

        user = lib.mkOption {
          type = str;
          default = "nobody";
          description = "User to run the service as";
        };

        group = lib.mkOption {
          type = str;
          default = "nobody";
          description = "Group to run the service as";
        };

        type = lib.mkOption {
          type = str;
          default = "simple";
          description = "Systemd service type";
        };

        execStart = lib.mkOption {
          type = str;
          description = "Command to start the service";
        };

        execReload = lib.mkOption {
          type = nullOr str;
          default = null;
          description = "Command to reload the service";
        };

        workingDirectory = lib.mkOption {
          type = nullOr str;
          default = null;
          description = "Working directory for the service";
        };

        stateDirectory = lib.mkOption {
          type = nullOr str;
          default = null;
          description = "State directory name";
        };

        stateDirectoryMode = lib.mkOption {
          type = str;
          default = "0750";
          description = "Mode for state directory";
        };

        dynamicUser = lib.mkOption {
          type = bool;
          default = true;
          description = "Use DynamicUser when not creating system user";
        };

        privateTmp = lib.mkOption {
          type = bool;
          default = true;
          description = "Use private /tmp";
        };

        protectSystem = lib.mkOption {
          type = bool;
          default = true;
          description = "Enable system protection";
        };

        protectHome = lib.mkOption {
          type = bool;
          default = true;
          description = "Enable home protection";
        };

        restart = lib.mkOption {
          type = str;
          default = "on-failure";
          description = "Restart policy";
        };

        restartSec = lib.mkOption {
          type = str;
          default = "5s";
          description = "Restart delay";
        };

        environment = lib.mkOption {
          type = attrsOf str;
          default = {};
          description = "Environment variables";
        };

        extraConfig = lib.mkOption {
          type = attrsOf anything;
          default = {};
          description = "Extra systemd service configuration";
        };
      };
    };
  };
in {
  options.local.http = lib.mkOption {
    type = attrsOf serviceType;
    default = {};
    description = "HTTP services configuration";
  };

  config = mkIf (cfg != {}) {
    services.nginx = enabled' {
      virtualHosts = cfg |> mapAttrsToList mkVirtualHost |> listToAttrs;
    };

    services.dnsmasq = {
      settings.address = mapAttrsToList mkDnsmasqAddress cfg;
    };

    systemd.services = listToAttrs (mapAttrsToList mkSystemdService cfg);

    users.users = mkMerge (mapAttrsToList (
        name: service:
          mkIf (service.systemd.enable && service.systemd.createSystemUser) {
            ${service.systemd.user} = {
              isSystemUser = true;
              group = service.systemd.group;
            };
          }
      )
      cfg);

    users.groups = mkMerge (mapAttrsToList (
        name: service:
          mkIf (service.systemd.enable && service.systemd.createSystemUser) {
            ${service.systemd.group} = {};
          }
      )
      cfg);

    networking.firewall.allowedTCPPorts = [80 443];
  };
}
