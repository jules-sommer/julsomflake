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
    ;
  inherit
    (helpers)
    enabled
    enabled'
    mkEnableOpt
    enabledPred
    ;

  cfg = config.local.wayland.plasma;
in {
  options.local.wayland.plasma =
    mkEnableOpt "Enable KDE Plasma 6 via wayland."
    // {
      extraPackages = mkEnableOpt "Enable a selection of extra kdePackages.";
    };
  config = foldl' recursiveUpdate {} [
    (mkIf cfg.enable {
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
          discover # Optional: Install if you use Flatpak or fwupd firmware update sevice
          kcalc # Calculator
          kcharselect # Tool to select and copy special characters from all installed fonts
          kclock # Clock app
          kcolorchooser # A small utility to select a color
          kolourpaint # Easy-to-use paint program
          ksystemlog # KDE SystemLog Application
          sddm-kcm # Configuration module for SDDM
          isoimagewriter # Optional: Program to write hybrid ISO files onto USB disks
          partitionmanager # Optional: Manage the disk devices, partitions and file systems on your computer
        ])
        ++ (with pkgs; [
          kdiff3 # Compares and merges 2 or 3 files or directories
          hardinfo2 # System information and benchmarks for Linux systems
          vlc # Cross-platform media player and streaming server
          wayland-utils # Wayland utilities
          wl-clipboard # Command-line copy/paste utilities for Wayland
        ]);
    })
  ];
}
