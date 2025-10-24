let
  whoogle_domain = "search.local";
in {
  services.nginx.virtualHosts.${whoogle_domain} = {
    forceSSL = true;
    enableACME = true;
    sslCertificate = "/var/lib/acme/certs/${whoogle_domain}/fullchain.pem";
    sslCertificateKey = "/var/lib/acme/certs/${whoogle_domain}/key.pem";

    locations."/" = {
      proxyPass = "http://127.0.0.1:5000";
      proxyWebsockets = true;
      extraConfig = ''
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
      '';
    };
  };
}
