{
  pkgs,
  lib,
  helpers,
  config,
  ...
}: let
  inherit
    (lib)
    foldl'
    recursiveUpdate
    mkIf
    enabled
    enabled'
    mkEnableOpt
    enabledPred
    ;

  cfg = config.local.wayland;
  isPlasmaActiveCompositor = cfg.activeCompositor == "plasma";
in {
  options.local.wayland.plasma = {
    extraPackages = mkEnableOpt "Enable a selection of extra kdePackages.";
  };
  config = mkIf isPlasmaActiveCompositor {
    services = {
      desktopManager.plasma6 = enabled;
      displayManager = {
        sddm = enabled' {
          wayland = enabled;
        };
      };
    };

    environment.systemPackages =
      (with pkgs.kdePackages; [
        kcharselect # Tool to select and copy special characters from all installed fonts
        kclock # Clock app
        kcolorchooser # A small utility to select a color
        kolourpaint # Easy-to-use paint program
        ksystemlog # KDE SystemLog Application
        sddm-kcm # Configuration module for SDDM
      ])
      ++ (with pkgs; [
        kdiff3 # Compares and merges 2 or 3 files or directories
        hardinfo2 # System information and benchmarks for Linux systems
        vlc # Cross-platform media player and streaming server
        wayland-utils # Wayland utilities
        wl-clipboard # Command-line copy/paste utilities for Wayland
      ]);
  };
}
