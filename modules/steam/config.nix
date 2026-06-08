{
  pkgs,
  lib,
  config,
  ...
}: let
  inherit (lib) optional optionals concatLists;
  cfg = config.local.gaming;
in {
  nixpkgs.config.allowUnfreePredicate = pkg:
    cfg.enable
    && builtins.elem (lib.getName pkg) [
      "steam"
      "steam-unwrapped"
    ];

  # TODO: this is a steam module but also like i didn't
  # wanna put this elsewhere

  local.home.home.packages = concatLists [
    (optional cfg.enable pkgs.heroic)
    (optionals cfg.steam.proton.enable (with pkgs; [protontricks zenity wine winetricks]))
  ];

  programs = {
    gamemode.enable = cfg.enable;

    steam = {
      inherit (cfg.steam) enable;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;

      extraCompatPackages = optionals cfg.steam.proton.enable (with pkgs; [
        proton-ge-bin
        protonup-qt
      ]);
    };
  };
}
