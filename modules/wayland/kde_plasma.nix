{
  pkgs,
  lib,
  config,
  ...
}: let
  inherit
    (lib)
    concatLists
    optionals
    mkEnableOpt
    mkEnableOption
    ;

  cfg = config.local.wayland.plasma;
in {
  options.local.wayland.plasma = {
    enable = mkEnableOption "plasma6";
    extraPackages = mkEnableOpt "extra kde packages.";
  };
  config = {
    services = {
      desktopManager.plasma6 = {inherit (cfg) enable;};
      displayManager = {
        sddm = {
          inherit (cfg) enable;
          wayland = {inherit (cfg) enable;};
        };
      };
    };

    environment.systemPackages = concatLists [
      (optionals cfg.extraPackages.enable (with pkgs.kdePackages; [
        kcharselect # Tool to select and copy special characters from all installed fonts
        kclock # Clock app
        kcolorchooser # A small utility to select a color
        kolourpaint # Easy-to-use paint program
        ksystemlog # KDE SystemLog Application
        sddm-kcm # Configuration module for SDDM
      ]))
      (optionals cfg.extraPackages.enable (with pkgs; [
        kdiff3 # Compares and merges 2 or 3 files or directories
        hardinfo2 # System information and benchmarks for Linux systems
        vlc # Cross-platform media player and streaming server
        wayland-utils # Wayland utilities
        wl-clipboard # Command-line copy/paste utilities for Wayland
      ]))
    ];
  };
}
