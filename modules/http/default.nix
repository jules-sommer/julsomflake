{lib, ...}: let
  inherit (lib) enabled' foldlAttrs getModulesRecursive;
  forgejo_domain = "git.local";
  services = {
    forgejo = {
      domain = "git.local";
      ports = {
        internal = 3000;
      };
      ssl = true;
    };
    vaultwarden = {
      domain = "vault.local";
      ssl = true;
    };

    whoogle = {
      domain = "search.local";
      ssl = true;
    };
  };
in {
  imports = getModulesRecursive ./. {max-depth = 1;};
  networking.firewall.allowedTCPPorts = [80 443];

  security.acme = {
    acceptTerms = true;
    email = "jsomme@pm.me";
    certs =
      foldlAttrs (acc: name: service:
        acc
        // {
          ${service.domain} = {
            webroot = "/var/lib/acme/${name}";
          };
        })
      {}
      services;
  };

  services.nginx = enabled' {
    virtualHosts.${forgejo_domain} = {
      forceSSL = true;
      locations."/".proxyPass = "http://127.0.0.1:3000";
      extraConfig = ''
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
      '';
      sslCertificate = "/var/lib/acme/certs/${forgejo_domain}/fullchain.pem";
      sslCertificateKey = "/var/lib/acme/certs/${forgejo_domain}/key.pem";
    };
  };
}
