{
  pkgs,
  lib,
  config,
  ...
}: let
  inherit
    (lib)
    enabled'
    cmdList
    disabled
    cmd
    getBinary
    ;

  eww = getBinary pkgs.eww;

  cfg = config.local.wayland;
  isNiriActiveCompositor = cfg.activeCompositor == "niri";
  niriPkg = pkgs.niri.overrideAttrs {doCheck = false;};

  binaries = {
    wbg = getBinary pkgs.wbg;
    fish = getBinary pkgs.fish;
    kitty = getBinary pkgs.kitty;
    zen = getBinary pkgs.zen-browser;
    vesktop = getBinary pkgs.vesktop;
    legcord = getBinary pkgs.legcord;
    signal = getBinary pkgs.signal-desktop;
    waybar = getBinary pkgs.waybar;
  };
in {
  config = {
    # install niri system wide.
    programs.niri = enabled' {package = niriPkg;};

    # disable niri-flake's binary cache, we provide our own niri package.
    niri-flake.cache = disabled;

    environment.systemPackages = with pkgs; [xwayland-satellite nautilus];
    local.home.programs.niri = {
      package = niriPkg;
      settings = {
        xwayland-satellite = enabled' {path = getBinary pkgs.xwayland-satellite;};
        overview = {
          zoom = 0.5;
        };

        recent-windows = enabled' {
          binds = {
            "Mod+Tab".action.next-window = {};
            "Mod+Shift+Tab".action.previous-window = {};
            "Mod+grave".action.next-window = {filter = "app-id";};
            "Mod+Shift+grave".action.previous-window = {filter = "app-id";};
          };
        };

        gestures = {
          hot-corners = disabled;
        };

        cursor = {
          inherit (config.stylix.cursor) size;
          theme = config.stylix.cursor.name;
          hide-when-typing = true;
          hide-after-inactive-ms = 1000;
        };

        spawn-at-startup = with binaries; [
          {sh = cmd [kitty];}
          {sh = cmd [zen];}
          {sh = cmd [legcord];}
          {sh = cmd [signal];}
          {sh = cmd ["wbg" "$WALLPAPER" "-s"];}
          {sh = cmd [waybar];}
        ];

        prefer-no-csd = true;
        hotkey-overlay.skip-at-startup = true;

        environment = {
          NIXOS_OZONE_WL = "1";
          ELECTRON_OZONE_PLATFORM_HINT = "wayland";
        };

        workspaces = {
          media = {
            open-on-output = "DP-1";
          };
          browser = {
            open-on-output = "DP-1";
          };
          chat = {
            open-on-output = "DP-1";
          };
          zig = {
            open-on-output = "HDMI-A-1";
          };
          nix = {
            open-on-output = "HDMI-A-1";
          };
        };
      };
    };
  };
}
