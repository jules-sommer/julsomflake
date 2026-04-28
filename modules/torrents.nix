{
  helpers,
  pkgs,
  ...
}: let
  inherit (helpers) enabled';
in {
  users.users.jules.extraGroups = ["qbittorrent"];
  environment.systemPackages = with pkgs; [
    qbittorrent-cli
    qbittorrent
  ];
  services.qbittorrent = enabled' {
    openFirewall = true;
    torrentingPort = 52371;
    webuiPort = 8088;
  };
}
