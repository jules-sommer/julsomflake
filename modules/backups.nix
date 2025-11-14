{
  pkgs,
  lib,
  config,
  src,
  ...
}: let
  inherit (lib) enabled';

  commonExcludes = [
    "**/.cache/"
    "**/.zig-out/"
    "**/.cargo/"
    "**/node_modules/"
    "**/target/"
    "/nix/store/"
    "**/pkg/mod/"

    "!.git-crypt-key"
    ".vscode/"
    ".DS_Store"
    "Thumbs.db"
    "!.envrc"
  ];
in {
  age.secrets = {
    restic-password = {
      file = lib.path.append src "secrets/restic-password.age";
      mode = "400";
      owner = "root";
      group = "root";
    };

    restic-htpasswd = {
      file = lib.path.append src "secrets/restic-htpasswd.age";
      path = "/mnt/BACKUPS/restic-server-repos/.htpasswd";
      mode = "644";
    };
  };

  services.restic = {
    server = enabled' {
      dataDir = "/mnt/BACKUPS/restic-server-repos";
    };
    backups = {
      home = {
        paths = ["/home/jules"];
        repository = "/mnt/BACKUPS/restic-repo";
        passwordFile = config.age.secrets.wifi-rcmp-surveillance.path;

        timerConfig = {
          OnUnitActiveSec = "14d";
          Persistent = true;
        };

        pruneOpts = [
          "--keep-daily 7"
          "--keep-weekly 4"
          "--keep-monthly 6"
        ];

        exclude =
          [
            "!/home/jules/.mariadb_history"
            "!/home/jules/.mysql"
            "!/home/jules/.local"
            "!/home/jules/.secrets"
            "!/home/jules/.nix-profile"
            "!/home/jules/.age/**"
            "!/home/jules/.ssh"
            "!/home/jules/.ssh/**"
            "/home/jules/.*"

            "/home/jules/Games/Heroic"
          ]
          ++ commonExcludes;
      };
    };
  };
}
