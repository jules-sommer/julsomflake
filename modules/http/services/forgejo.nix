{
  lib,
  config,
  src,
  ...
}: let
  inherit (lib) optionalAttrs enabled';
  cfg = config.services.forgejo;
  srv = cfg.settings.server;
in {
  services.dnsmasq = enabled' {
    settings.address = "/git.lan/127.0.0.1";
  };

  users = {
    users.forgejo = optionalAttrs cfg.enable {
      group = "forgejo";
      isSystemUser = true;
      uid = 879;
    };
    groups.forgejo = optionalAttrs cfg.enable {
      gid = config.users.users.forgejo.uid;
    };
  };

  services.nginx = {
    virtualHosts.${srv.DOMAIN} = {
      forceSSL = false;
      enableACME = false;
      extraConfig = ''
        client_max_body_size 512M;
      '';
      locations."/".proxyPass = "http://localhost:${toString srv.HTTP_PORT}";
    };
  };

  services.forgejo = enabled' {
    database.type = "sqlite3";
    # Enable support for Git Large File Storage
    lfs.enable = true;
    settings = {
      server = {
        DOMAIN = "git.lan";
        # You need to specify this to remove the port from URLs in the web UI.
        ROOT_URL = "http://${srv.DOMAIN}/";
        HTTP_PORT = 3000;
      };
      # You can temporarily allow registration to create an admin user.
      service.DISABLE_REGISTRATION = false;

      # Add support for actions, based on act: https://github.com/nektos/act
      actions = {
        ENABLED = true;
        DEFAULT_ACTIONS_URL = "github";
      };
      # Sending emails is completely optional
      # You can send a test email from the web UI at:
      # Profile Picture > Site Administration > Configuration >  Mailer Configuration
      mailer = {
        ENABLED = false;
        SMTP_ADDR = "mail.example.com";
        FROM = "noreply@${srv.DOMAIN}";
        USER = "noreply@${srv.DOMAIN}";
      };
    };
    secrets = {
      # mailer.PASSWD = config.age.secrets.forgejo-mailer-password.path;
    };
  };

  # age.secrets.forgejo-mailer-password = {
  #   file = lib.path.append src "secrets/forgejo-mailer-password.age";
  #   mode = "400";
  #   owner = "forgejo";
  # };
}
