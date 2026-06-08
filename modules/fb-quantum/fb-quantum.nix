{
  pkgs,
  lib,
  ...
}: let
  inherit (lib) mkOption mkEnableOption mkPackageOption types;
  format = pkgs.formats.yaml {};
in {
  options.services.filebrowser-quantum = {
    enable = mkEnableOption "FileBrowser Quantum, a self-hosted web file manager";

    package = mkPackageOption pkgs "filebrowser-quantum" {};

    user = mkOption {
      type = types.str;
      default = "filebrowser-quantum";
      description = "User account under which FileBrowser Quantum runs.";
    };

    group = mkOption {
      type = types.str;
      default = "filebrowser-quantum";
      description = "Group under which FileBrowser Quantum runs.";
    };

    openFirewall = mkEnableOption "opening the configured server port in the firewall";

    environmentFile = mkOption {
      type = types.nullOr types.path;
      default = null;
      example = "/run/agenix/filebrowser-quantum.env";
      description = ''
        Path to a systemd `EnvironmentFile` holding secrets such as
        `FILEBROWSER_ADMIN_PASSWORD`, `FILEBROWSER_JWT_TOKEN_SECRET`, or
        `FILEBROWSER_OIDC_CLIENT_SECRET`. Keeps secrets out of the
        world-readable Nix store.
      '';
    };

    settings = mkOption {
      default = {};
      description = ''
        Configuration rendered verbatim to FileBrowser Quantum's `config.yaml`.
        See <https://filebrowserquantum.com/en/docs/configuration/configuration-overview/>.
      '';
      type = types.submodule {
        freeformType = format.type;

        options.server = mkOption {
          default = {};
          type = types.submodule {
            freeformType = format.type;

            options = {
              port = mkOption {
                type = types.port;
                default = 8080;
                description = "Port the server listens on.";
              };

              listen = mkOption {
                type = types.str;
                default = "localhost";
                description = "Address the server binds to. Defaults to loopback for use behind a reverse proxy.";
              };

              database = mkOption {
                type = types.path;
                default = "/var/lib/filebrowser-quantum/database.db";
                description = "Path to the index/configuration database file.";
              };

              cacheDir = mkOption {
                type = types.path;
                default = "/var/cache/filebrowser-quantum";
                description = "Directory for temporary preview, archive, and conversion files.";
              };

              sources = mkOption {
                default = [
                  {
                    path = "/var/lib/filebrowser-quantum/data";
                    config.defaultEnabled = true;
                  }
                ];
                description = "Filesystem sources exposed through the web interface.";
                type = types.listOf (
                  types.submodule {
                    freeformType = format.type;
                    options.path = mkOption {
                      type = types.path;
                      description = "Real filesystem path of the source. Used internally as the source's identity.";
                    };
                  }
                );
              };
            };
          };
        };
      };
    };
  };
}
