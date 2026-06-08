_: let
  domain = "pics.julsom.link";
  port = 2283;
in {
  services.immich = {
    inherit port;
    enable = true;
    host = "127.0.0.1";
    openFirewall = false;
  };

  services.caddy.virtualHosts.${domain}.extraConfig = ''
    reverse_proxy 127.0.0.1:${toString port}
  '';
}
