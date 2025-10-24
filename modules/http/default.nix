{lib, ...}: let
  inherit (lib) enabled';
  forgejo_domain = "git.local";
in {
  imports = [./mod.nix];
  networking.firewall.allowedTCPPorts = [80 443];

  security.acme = {
    acceptTerms = true;
    email = "jsomme@pm.me";
    certs = {
      ${forgejo_domain} = {
        webroot = "/var/lib/acme/forgejo";
      };
    };
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
