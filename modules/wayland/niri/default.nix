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
    mkEnableOpt
    cmd
    mkCmd
    mkBefore
    getExe
    getExe'
    ;

  # niri-session-init = pkgs.writeShellScriptBin "niri-session-init" ''
  #   ${pkgs.dbus}/bin/dbus-update-activation-environment --systemd --all
  #   ${pkgs.systemd}/bin/systemctl --user import-environment PATH
  #   ${pkgs.systemd}/bin/systemctl --user restart xdg-desktop-portal.service \
  #                                                 plasma-xdg-desktop-portal-kde.service \
  #                                                 xdg-desktop-portal-gtk.service \
  #                                                 xdg-document-portal.service \
  #                                                 xdg-permission-store.service
  # '';

  niri = getExe' pkgs.niri-unstable "niri-session";
  tuigreet = getExe pkgs.tuigreet;

  binaries = {
    wbg = mkCmd [(getExe pkgs.wbg)];
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
    notify-send = getExe' pkgs.libnotify "notify-send";
  };
in {
  options.local.wayland.niri = mkEnableOpt "niri module";
  config = {
    programs.niri = enabled' {package = pkgs.niri-unstable;};
    niri-flake.cache = disabled;
    environment.systemPackages = with pkgs; [xwayland-satellite nautilus];
    services.greetd.settings.default_session.command = "${tuigreet} --cmd ${niri}";
    local.home.programs.niri = {
      package = pkgs.niri-unstable;
      settings = {
        screenshot-path = "/home/jules/060_media/005_screenshots";
        xwayland-satellite = enabled' {path = binaries.xwayland-satellite;};

        overview.zoom = 0.5;
        gestures.hot-corners = disabled;
        prefer-no-csd = true;

        # TODO: This is commented out because the niri-flake we're using doesn't
        #       support these options.

        # hotkey-overlay.skip-at-startup = true;

        # recent-windows = enabled' {
        #   binds = {
        #     "Mod+Tab".action.next-window = {};
        #     "Mod+Shift+Tab".action.previous-window = {};
        #     "Mod+grave".action.next-window = {filter = "app-id";};
        #     "Mod+Shift+grave".action.previous-window = {filter = "app-id";};
        #   };
        # };

        blur = {
          passes = 3;
          offset = 2.0;
          noise = 0.015;
          saturation = 1.5;
        };

        cursor = {
          inherit (config.stylix.cursor) size;
          theme = config.stylix.cursor.name;
          hide-when-typing = true;
          hide-after-inactive-ms = 1000;
        };

        spawn-at-startup = with binaries; [
          (mkBefore {command = [kded6];})
          {sh = cmd [kitty];}
          {sh = cmd [zen];}
          {sh = cmd [legcord];}
          {sh = cmd [signal];}
          {sh = cmd [helium];}
          # {sh = wbg ["-s" "$WALLPAPER"];}
        ];

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
          media.open-on-output = "DP-1";
          browser.open-on-output = "DP-1";
          chat.open-on-output = "DP-1";
          zig.open-on-output = "HDMI-A-1";
          nix.open-on-output = "HDMI-A-1";
        };
      };
    };
  };
}
