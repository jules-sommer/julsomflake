{
  lib,
  src,
  ...
}: let
  domain = "ntfy.julsom.link";
  port = 2586;
in {
  age.secrets.ntfy-token = {
    file = lib.path.append src "secrets/ntfy-token-env.age";
    mode = "400";
    owner = "jules";
    group = "root";
  };

  services = {
    ntfy-sh = {
      enable = true;
      settings = {
        base-url = "https://${domain}";
        listen-http = "127.0.0.1:${port |> toString}";
        auth-file = "/var/lib/ntfy-sh/auth.db";
        auth-default-access = "deny-all";
        behind-proxy = true;
        enable-login = true;
        enable-signup = false;
      };
    };
    caddy.virtualHosts.${domain}.extraConfig = ''
        tls {
          dns cloudflare {env.CLOUDFLARE_API_TOKEN}
        }
      reverse_proxy 127.0.0.1:${port |> toString}
    '';
  };
}
