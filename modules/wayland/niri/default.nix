{
  pkgs,
  helpers,
  inputs,
  config,
  ...
}: let
  inherit
    (helpers)
    mkEnableOpt
    enabledPred
    enabled
    ;
  inherit (inputs) niri-flake;
  cfg = config.local.wayland.niri;
in {
  options.local.wayland.niri = mkEnableOpt "Enable niri.";

  config = {
    nixpkgs.overlays = [niri-flake.overlays.niri];

    # install niri package at the system level for interaction with systemd
    programs.niri = enabledPred cfg.enable {
      package = pkgs.niri-unstable;
    };

    # home-manager settings for niri
    local.home = {
      programs.niri = {
        package = null;
        settings = {
          input = {
            warp-mouse-to-focus = enabled;
            focus-follows-mouse = enabled;
            mod-key = "Super";
            mod-key-nested = "Alt";
            mouse = {
              natural-scroll = true;
              accel-speed = 0.2;
              accel-profile = "adaptive";
              scroll-factor = 1.25;
              scroll-method = "on-button-down";
              scroll-button = 274;
            };
            keyboard = {
              xkb = {
                layout = "us";
                options = "ctrl:swap_rwin_rctl,compose:ralt,caps:swapescape";
              };
              repeat-delay = 200;
              repeat-rate = 50;
            };
          };

          outputs = {
            DP-1 = {
              mode = {
                # 2560x1080@74.990997
                width = 2560;
                height = 1080;
                refresh = 74.990997;
              };
              transform = {};
              position = {
                x = 1920;
                y = 0;
              };
              scale = 1.0;
            };
            HDMI-A-1 = {
              mode = {
                # 1920x1080@60.000000
                height = 1920;
                width = 1080;
                refresh = 60.000000;
              };
              transform = {};
              position = {
                x = 0;
                y = 0;
              };
              scale = 1.0;
            };
          };

          cursor = {
            theme = "Bibata-Modern-Ice";
            size = 32;
            hide-when-typing = true;
            hide-after-inactive-ms = 1000;
          };

          spawn-at-startup = [
            {command = ["kitty"];}
            {command = ["rivertile"];}
            {command = ["/home/jules/000_dev/010_zig/river-conf/zig-out/bin/river_conf"];}
            {command = ["wbg" "/home/jules/060_media/010_wallpapers/zoe-love-bg/zoe-love-4k.png"];}
            {command = ["river-bnf"];}
          ];

          prefer-no-csd = true;

          hotkey-overlay = {
            skip-at-startup = true;
          };

          binds = {
            "Mod+Escape".action."toggle-keyboard-shortcuts-inhibit" = [];
            "Mod+Z".action.spawn = "zen";
            "Mod+Space".action.spawn = "fuzzel";
            "Mod+Return".action.spawn = "kitty";
            "Mod+Shift+E".action.spawn = ["wleave" "-p" "layer-shell"];
            "Mod+E" = {
              allow-inhibiting = false;
              action.spawn = [
                "swaylock"
                "--indicator-idle-visible"
                "-e"
                "-F"
                "-i"
                "/home/jules/060_media/010_wallpapers/zoe-love-bg/zoe-love-4k.png"
              ];
            };
            "Mod+Shift+Slash".action."show-hotkey-overlay" = [];

            "Mod+H".action."focus-column-left" = [];
            "Mod+J".action."focus-window-down" = [];
            "Mod+K".action."focus-window-up" = [];
            "Mod+L".action."focus-column-right" = [];
            "Mod+Comma".action."focus-monitor-left" = [];
            "Mod+Period".action."focus-monitor-right" = [];
            "Mod+Shift+Comma".action."move-column-to-monitor-left" = [];
            "Mod+Shift+Period".action."move-column-to-monitor-right" = [];

            "Mod+Ctrl+H".action."move-column-left" = [];
            "Mod+Ctrl+J".action."move-window-down" = [];
            "Mod+Ctrl+K".action."move-window-up" = [];
            "Mod+Ctrl+L".action."move-column-right" = [];

            "Mod+Home".action."focus-column-first" = [];
            "Mod+End".action."focus-column-last" = [];
            "Mod+Ctrl+Home".action."move-column-to-first" = [];
            "Mod+Ctrl+End".action."move-column-to-last" = [];

            "Mod+U".action."focus-workspace-up" = [];
            "Mod+I".action."focus-workspace-down" = [];
            "Mod+Ctrl+U".action."move-column-to-workspace-up" = [];
            "Mod+Ctrl+I".action."move-column-to-workspace-down" = [];
            "Mod+Shift+U".action."move-workspace-up" = [];
            "Mod+Shift+I".action."move-workspace-down" = [];

            "Mod+Alt+H".action."consume-window-into-column" = [];
            "Mod+Alt+L".action."expel-window-from-column" = [];
            "Mod+R".action."switch-preset-column-width" = [];
            "Mod+F".action."maximize-column" = [];
            "Mod+Shift+F".action."fullscreen-window" = [];
            "Mod+C".action."center-column" = [];

            "Mod+Minus".action."set-column-width" = "-10%";
            "Mod+Equal".action."set-column-width" = "+10%";
            "Mod+Shift+Minus".action."set-window-height" = "-10%";
            "Mod+Shift+Equal".action."set-window-height" = "+10%";

            "Mod+Print".action."screenshot" = [];
            "Ctrl+Print".action."screenshot-screen" = [];
            "Alt+Print".action."screenshot-window" = [];
            "Mod+Shift+P".action."power-off-monitors" = [];
          };

          environment = {
            "-ELECTRON_OZONE_PLATFORM_HINT" = "wayland";
          };
        };
      };
    };
  };
}
