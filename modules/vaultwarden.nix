{
  lib,
  pkgs,
  src,
  config,
  ...
}: let
  port = 8222;
  domain = "vault.estradiol.ca";
in {
  age.secrets.vaultwarden-env = {
    file = lib.path.append src "secrets/vaultwarden-env.age";
    mode = "400";
    owner = "vaultwarden";
    group = "vaultwarden";
  };

  services.vaultwarden = {
    enable = true;
    environmentFile = config.age.secrets.vaultwarden-env.path;
    config = {
      DOMAIN = "https://${domain}";
      ROCKET_ADDRESS = "127.0.0.1";
      ROCKET_PORT = port;
      SIGNUPS_ALLOWED = false;
      SIGNUPS_VERIFY = true;
      LOGIN_RATELIMIT_MAX_BURST = 10;
      LOGIN_RATELIMIT_SECONDS = 60;
      ADMIN_RATELIMIT_MAX_BURST = 5;
      ADMIN_RATELIMIT_SECONDS = 60;
    };
  };

  services.caddy.virtualHosts.${domain} = {
    extraConfig = ''
      tls {
        dns cloudflare {env.CLOUDFLARE_API_TOKEN}
      }
      reverse_proxy 127.0.0.1:${toString port}
    '';
  };
}
