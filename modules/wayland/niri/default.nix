{
  pkgs,
  lib,
  config,
  ...
}: let
  inherit
    (lib)
    enabled'
    disabled
    cmd
    mkBefore
    getExe
    ;

  niri-session-init = pkgs.writeShellScriptBin "niri-session-init" ''
    ${pkgs.dbus}/bin/dbus-update-activation-environment --systemd --all
    ${pkgs.systemd}/bin/systemctl --user import-environment PATH
    ${pkgs.systemd}/bin/systemctl --user restart xdg-desktop-portal.service \
                                                  plasma-xdg-desktop-portal-kde.service \
                                                  xdg-desktop-portal-gtk.service \
                                                  xdg-document-portal.service \
                                                  xdg-permission-store.service
  '';

  binaries = {
    wbg = getExe pkgs.wbg;
    fish = getExe pkgs.fish;
    kitty = getExe pkgs.kitty;
    zen = getExe pkgs.zen-browser;
    vesktop = getExe pkgs.vesktop;
    legcord = getExe pkgs.legcord;
    signal = getExe pkgs.signal-desktop;
    waybar = getExe pkgs.waybar;
    kded6 = getExe pkgs.kdePackages.kded;
    eww = getExe pkgs.eww;
    helium = getExe pkgs.helium;
    xwayland-satellite = getExe pkgs.xwayland-satellite;
  };
in {
  config = {
    # install niri system wide.
    programs.niri = enabled' {package = pkgs.niri;};

    # disable niri-flake's binary cache, we provide our own niri package.
    niri-flake.cache = disabled;

    environment.systemPackages = with pkgs; [xwayland-satellite nautilus];
    local.home.programs.niri = {
      package = pkgs.niri;
      settings = {
        screenshot-path = "/home/jules/060_media/005_screenshots";
        xwayland-satellite = enabled' {path = binaries.xwayland-satellite;};
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
          (mkBefore {sh = getExe niri-session-init;})
          (mkBefore {command = [kded6];})
          {sh = cmd [kitty];}
          {sh = cmd [zen];}
          {sh = cmd [legcord];}
          {sh = cmd [signal];}
          {sh = cmd [helium];}
          {sh = cmd [fish "-c" wbg "-s" "$WALLPAPER"];}
          {sh = cmd [waybar];}
        ];

        prefer-no-csd = true;
        hotkey-overlay.skip-at-startup = true;

        environment = {
          NIXOS_OZONE_WL = "1";
          ELECTRON_OZONE_PLATFORM_HINT = "auto";

          XDG_MENU_PREFIX = "plasma-";
          XDG_CURRENT_DESKTOP = "niri";

          QT_AUTO_SCREEN_SCALE_FACTOR = "1";
          QT_ENABLE_HIGHDPI_SCALING = "1";
          QT_SCALE_FACTOR_ROUNDING_POLICY = "RoundPreferFloor";

          QT_QPA_PLATFORM = "wayland";
          QT_QPA_PLATFORMTHEME = "kde";
          QT_QPA_PLATFORMTHEME_QT6 = "kde";
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
