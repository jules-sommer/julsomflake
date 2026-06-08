{
  pkgs,
  lib,
  config,
  src,
  ...
}: let
  forgejoTheme = pkgs.runCommand "forgejo-custom" {} ''
    mkdir -p $out/public/assets/{css,img}
    mkdir -p $out/templates/base

    cp ${./theme/theme-custom.css} $out/public/assets/css/theme-custom.css
    cp ${./theme/assets/favicon.svg} $out/public/assets/img/logo.svg
    cp ${./theme/assets/logo_horizontal.svg} $out/public/assets/img/favicon.svg
    cp ${./theme/head_navbar.tmpl} $out/templates/base/head_navbar.tmpl
  '';
in {
  age.secrets = {
    forgejo-secrets = {
      file = lib.path.append src "secrets/forgejo-secrets.age";
      mode = "400";
      owner = "forgejo";
      group = "forgejo";
    };
    forgejo-runner-token = {
      file = lib.path.append src "secrets/forgejo-runner-token.age";
      mode = "400";
      owner = "gitea-runner";
      group = "gitea-runner";
    };
  };

  users = {
    groups = {
      gitea-runner = {};
      forgejo.gid = config.users.users.forgejo.uid;
    };
    users = {
      gitea-runner = {
        isSystemUser = true;
        group = "gitea-runner";
      };
      forgejo = {
        group = "forgejo";
        isSystemUser = true;
        uid = 879;
      };
    };
  };
  systemd = {
    tmpfiles.rules = [
      "L+ /var/lib/forgejo/custom/public    - - - - ${forgejoTheme}/public"
      "L+ /var/lib/forgejo/custom/templates - - - - ${forgejoTheme}/templates"
    ];
    services = {
      gitea-runner-estradiol.serviceConfig = {
        DynamicUser = lib.mkForce false;
        User = lib.mkForce "gitea-runner";
        Group = lib.mkForce "gitea-runner";
      };
      forgejo = {
        serviceConfig.EnvironmentFile =
          config.age.secrets.forgejo-secrets.path;
      };
    };
  };

  services = {
    gitea-actions-runner.instances.estradiol = {
      enable = true;
      name = "estradiol";
      url = "https://git.estradiol.ca";
      tokenFile = config.age.secrets.forgejo-runner-token.path;
      labels = ["native:host"];
    };
    forgejo = {
      enable = true;
      database.type = "sqlite3";
      settings = {
        ui = {
          DEFAULT_THEME = "custom";
          THEMES = "forgejo-auto,forgejo-light,forgejo-dark,custom";
        };
        actions.ENABLED = true;
        server = {
          DOMAIN = "git.estradiol.ca";
          ROOT_URL = "https://git.estradiol.ca";
          HTTP_PORT = 3000;
          HTTP_ADDR = "127.0.0.1";
        };
        service.DISABLE_REGISTRATION = true;
        mailer = {
          ENABLED = true;
          PROTOCOL = "smtps";
          SMTP_ADDR = "smtp.protonmail.ch";
          SMTP_PORT = 587;
          FROM = "git@estradiol.ca";
          USER = "git@estradiol.ca";
        };
      };
    };
  };
}
