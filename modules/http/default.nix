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
    defaults.email = "jsomme@pm.me";
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

  services.nginx =
    enabled' {
    };
}
