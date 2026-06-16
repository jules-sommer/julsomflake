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

  environment.systemPackages = with pkgs; [
    nmap
    nmap-formatter
  ];

  local.home.home.packages = with pkgs; [
    protonvpn-gui
  ];

  programs = {
    mtr = enabled;
  };

  networking = {
    firewall = enabled' {
      allowedTCPPorts = [80 443 52371];
      allowedUDPPorts = [52371];
    };
    nftables = enabled;

    networkmanager = enabled' {
      ensureProfiles = {
        environmentFiles = [config.age.secrets.wifi-rcmp-surveillance.path];
        profiles = {
          rcmp_surveillance_5ghz = {
            connection = {
              id = "RCMP Surveillance 5GHz";
              interface-name = "wlp15s0";
              type = "wifi";
              uuid = "9fa178a4-ca78-4404-81f4-260c65e257e5";
            };
            ipv4 = {method = "auto";};
            ipv6 = {
              addr-gen-mode = "default";
              method = "auto";
            };
            proxy = {};
            wifi = {
              mode = "infrastructure";
              ssid = "RCMP Surveillance 5GHz";
            };
            wifi-security = {
              key-mgmt = "sae";
              psk = "$WIFI_PSK";
            };
          };
          rcmp_surveillance = {
            connection = {
              id = "RCMP Surveillance";
              permissions = "user:jules:;";
              timestamp = "1777408539";
              type = "wifi";
              uuid = "de31260e-ddb8-41c5-a60e-03d76a379417";
            };
            ipv4 = {method = "auto";};
            ipv6 = {
              addr-gen-mode = "stable-privacy";
              method = "auto";
            };
            proxy = {};
            wifi = {
              mode = "infrastructure";
              ssid = "RCMP Surveillance";
            };
            wifi-security = {
              key-mgmt = "wpa-psk";
              psk = "$WIFI_PSK";
            };
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
