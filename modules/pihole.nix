{
  lib,
  pkgs,
  src,
  config,
  ...
}: let
  port = 8085;
  domain = "pihole.estradiol.ca";

  inherit (lib) toString;
in {
  age.secrets = {
    pihole-password = {
      file = lib.path.append src "secrets/pihole-password.age";
      mode = "400";
      owner = "pihole";
      group = "pihole";
    };
    pihole-totp-secret = {
      file = lib.path.append src "secrets/pihole-totp-secret.age";
      mode = "400";
      owner = "pihole";
      group = "pihole";
    };
  };

  networking = {
    networkmanager.dns = "none";
    nameservers = ["127.0.0.1" "9.9.9.9"];
  };

  system.activationScripts."pihole-env" = {
    deps = ["agenix"];
    text = ''
      {
        printf 'FTLCONF_webserver_api_pwhash=%s\n' \
          "$(cat ${config.age.secrets.pihole-password.path})"
        printf 'FTLCONF_webserver_api_totp_secret=%s\n' \
          "$(cat ${config.age.secrets.pihole-totp-secret.path})"
      } > ${config.services.pihole-ftl.stateDirectory}/pihole.env
      chmod 400 ${config.services.pihole-ftl.stateDirectory}/pihole.env
      chown pihole:pihole ${config.services.pihole-ftl.stateDirectory}/pihole.env
    '';
  };

  systemd.services.pihole-ftl.serviceConfig.EnvironmentFile = "${config.services.pihole-ftl.stateDirectory}/pihole.env";

  services = {
    caddy.virtualHosts.${domain} = {
      extraConfig = ''
        @lan remote_ip 192.168.1.0/24 127.0.0.1
        handle @lan {
          reverse_proxy 127.0.0.1:${toString port}
        }
        respond 403
        tls {
          dns cloudflare {env.CLOUDFLARE_API_TOKEN}
        }
      '';
    };

    pihole-ftl = {
      enable = true;
      openFirewallDNS = true;

      lists = [
        {
          url = "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts";
          type = "block";
          enabled = true;
          description = "Steven Black unified hosts - ads + malware";
        }
      ];

      settings = {
        webserver.interface.theme = "default-darker";
        dns = {
          upstreams = ["9.9.9.9" "1.1.1.1"];
          hosts = [
            "192.168.1.11 estradiol.ca"
            "192.168.1.11 git.estradiol.ca"
            "192.168.1.11 pihole.estradiol.ca"
            "127.0.0.1 localhost"
          ];
        };
      };
    };

    pihole-web = {
      enable = true;
      hostName = domain;
      ports = ["${toString port}"];
    };
  };
}
