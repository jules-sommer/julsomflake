{
  lib,
  src,
  config,
  pkgs,
  ...
}: let
  inherit (lib) enabled enabled';
in {
  time.timeZone = "America/Toronto";
  i18n.defaultLocale = "en_CA.UTF-8";

  age.secrets.wifi-rcmp-surveillance = {
    file = lib.path.append src "secrets/wifi-rcmp-surveillance.age";
    mode = "400";
    owner = "root";
    group = "root";
  };

  local.home.home.packages = with pkgs; [
    protonvpn-gui
  ];

  programs = {
    mtr = enabled;
  };

  networking = {
    firewall = enabled;
    nftables = enabled;

    networkmanager = enabled' {
      ensureProfiles = {
        profiles = {
          rcmp_surveillance = {
            connection = {
              id = "RCMP Surveillance 1";
              type = "wifi";
            };
            wifi = {
              ssid = "RCMP Surveillance";
              mode = "infrastructure";
            };
            wifi-sec = {
              key-mgmt = "sae";
              psk = "$(<${config.age.secrets.wifi-rcmp-surveillance.path})";
            };
            ipv4.method = "auto";
            ipv6.method = "auto";
          };
        };
      };
    };
  };

  services = {
    # LogLevel should be set to "VERBOSE" or higher
    # so that fail2ban can observe failed login attempts
    openssh.settings.LogLevel = "VERBOSE";

    fail2ban = enabled' {
      bantime = "1h";
      maxretry = 3;
      jails = {
        DEFAULT.settings = {
          findtime = "10m";
        };
      };
      ignoreIP = [
        "127.0.0.1/8"
        "::1"
        "192.168.1.0/24"
        "10.0.0.0/8"
        "172.16.0.0/12"
        "192.168.1.11"
        "192.168.1.99"
        "2001:1970:51a0:9000::/64"
      ];
    };
  };
}
