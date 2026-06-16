{
  pkgs,
  lib,
  config,
  src,
  ...
}: let
  makeRateLimit = zone: num-events: ''
    rate_limit {
      zone ${zone} {
        key {remote_host}
        events 100
        window 1m
      }
    }
  '';
  makeTlsHosts = domains:
    domains
    |> lib.concatMap (domain: [domain "*.${domain}"])
    |> (x:
      lib.genAttrs x (_: {
        extraConfig = ''
          tls {
            dns cloudflare {env.CLOUDFLARE_API_TOKEN}
          }
        '';
      }));
in {
  age.secrets.cloudflare-api-token = {
    file = lib.path.append src "secrets/cloudflare-api-token.age";
    mode = "400";
    owner = "caddy";
    group = "caddy";
  };

  networking.hosts = {
    "127.0.0.1" = [
      "estradiol.ca"
      "git.estradiol.ca"
      "pihole.estradiol.ca"
      "files.julsom.link"
      "vault.estradiol.ca"
      "julsom.link"
      "pics.julsom.link"
      "ntfy.julsom.link"
      "docs.julsom.link"
    ];
  };

  services.caddy = {
    enable = true;
    openFirewall = true;
    package = pkgs.caddy.withPlugins {
      plugins = [
        "github.com/caddy-dns/cloudflare@v0.2.4"
        "github.com/mholt/caddy-ratelimit@v0.1.0"
      ];
      hash = "sha256-Znp0BUV32YIYIWz4HK5BNDX7iZmQ8vFIX+Bci35sCsY=";
    };
    environmentFile = config.age.secrets.cloudflare-api-token.path;
    virtualHosts =
      (makeTlsHosts [
        "estradiol.ca"
        "julsom.link"
      ])
      // {
        # abort requests that don't match a valid domain.
        "http://:80".extraConfig = "abort";

        "julsom.link".extraConfig = ''
          ${makeRateLimit "julsom-dynamic" 100}
          respond "coming soon" 200
        '';

        "git.estradiol.ca".extraConfig = ''
          ${makeRateLimit "git-dynamic" 200}
          reverse_proxy 127.0.0.1:3000
        '';

        "estradiol.ca".extraConfig = ''
          ${makeRateLimit "estradiol-dynamic" 100}
          respond "coming soon" 200
        '';
      };
  };
}
