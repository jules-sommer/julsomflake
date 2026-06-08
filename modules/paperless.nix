{
  lib,
  src,
  config,
  ...
}: let
  domain = "docs.julsom.link";
  port = 28981;
in {
  age.secrets.paperless-admin-password = {
    file = lib.path.append src "secrets/paperless-admin-password.age";
    mode = "400";
    owner = "paperless";
    group = "paperless";
  };
  services = {
    scan2paperless = lib.enabled' {
      host = domain;
      user = "admin";
      passwordFile = config.age.secrets.paperless-admin-password.path;
    };
    paperless = {
      enable = true;
      inherit port;
      address = "127.0.0.1";
      passwordFile = config.age.secrets.paperless-admin-password.path;
      settings = {
        PAPERLESS_OCR_LANGUAGE = "eng";
        PAPERLESS_TIME_ZONE = "America/Toronto";
        PAPERLESS_URL = domain;
        PAPERLESS_CSRF_TRUSTED_ORIGINS = "https://${domain}";
        PAPERLESS_USE_X_FORWARD_HOST = "true";
        PAPERLESS_USE_X_FORWARD_PORT = "true";
        PAPERLESS_PROXY_SSL_HEADER = ''["HTTP_X_FORWARDED_PROTO", "https"]'';
      };
    };

    caddy.virtualHosts.${domain}.extraConfig = ''
      reverse_proxy 127.0.0.1:${toString port} {
        header_down Referrer-Policy "strict-origin-when-cross-origin"
      }
    '';
  };
}
