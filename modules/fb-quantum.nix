{config, ...}: {
  age.secrets.filebrowser-quantum.file = ../secrets/filebrowser-quantum.env.age;

  services.filebrowser-quantum = {
    enable = true;
    environmentFile = config.age.secrets.filebrowser-quantum.path;
    settings.server = {
      port = 8080;
      sources = [
        {
          path = "/home/jules/015_articles-&-research";
          config.defaultEnabled = true;
        }
        {
          path = "/srv/files";
          config.defaultEnabled = true;
        }
      ];
      externalUrl = "https://files.estradiol.ca";
    };
  };

  services.caddy.virtualHosts."files.estradiol.ca".extraConfig = ''
    reverse_proxy localhost:8080
  '';
}
