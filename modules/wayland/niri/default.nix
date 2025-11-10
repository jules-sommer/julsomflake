{
  pkgs,
  lib,
  helpers,
  inputs,
  config,
  ...
}: let
  inherit
    (helpers)
    mkEnableOpt
    enabled
    ;
  inherit (lib) mkIf enabled' isList isString concatStringsSep splitString;
  cfg = config.local.wayland.niri;
  niriPkg = inputs.niri.packages.${pkgs.system}.niri-stable.overrideAttrs {doCheck = false;};
  cmd = parts: concatStringsSep " " parts;
  spawn = command:
    if isList command
    then ["${pkgs.fish}/bin/fish" "-c" (cmd command)]
    else if isString command
    then let
      commandParts = splitString " " command;
    in
      ["${pkgs.fish}/bin/fish" "-c"] ++ commandParts
    else throw "Command provided to `spawn` must be either a list of strings or a string.";
in {
  options.local.wayland.niri = mkEnableOpt "Enable niri.";

  config = {
    programs.niri = enabled' {
      package = niriPkg;
    };
    local.home = {
      programs.niri = mkIf cfg.enable {
        package = niriPkg;
        settings = {
          input = {
            warp-mouse-to-focus.enable = true;
            focus-follows-mouse.enable = true;
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
                options = "compose:ralt";
                # options = "ctrl:swap_rwin_rctl,compose:ralt,caps:swapescape";
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
            theme = "BreezeX-RosePineDawn-Linux";
            size = 32;
            hide-when-typing = true;
            hide-after-inactive-ms = 1000;
          };

          spawn-at-startup = [
            {command = ["kitty"];}
            {
              command = [
                "wbg"
                "/home/jules/060_media/010_wallpapers/zoe-love-bg/zoe-love-4k.png"
              ];
            }
          ];

          prefer-no-csd = true;

          hotkey-overlay = {
            skip-at-startup = true;
          };

          binds = {
            "Mod+Escape".action.toggle-keyboard-shortcuts-inhibit = [];
            "Mod+Z".action.spawn = spawn "zen";
            "Mod+Space".action.spawn = spawn "fuzzel";
            "Mod+Shift+Return".action.spawn = spawn "fuzzel";
            "Mod+Return".action.spawn = spawn "kitty";
            "Mod+Shift+E".action.spawn = [
              "wleave"
              "-p"
              "layer-shell"
            ];
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
            "Mod+WheelScrollDown" = {
              cooldown-ms = 150;
              action.focus-workspace-down = [];
            };

            "Mod+WheelScrollUp".action.focus-workspace-up = [];
            "Mod+WheelScrollRight".action.focus-column-right = [];
            "Mod+WheelScrollLeft".action.focus-column-left = [];

            "XF86AudioRaiseVolume".action.spawn = spawn "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1+";
            "XF86AudioLowerVolume".action.spawn = spawn "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1-";
            "XF86AudioMute".action.spawn = spawn "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";

            "XF86MonBrightnessUp".action.spawn = spawn "brightnessctl set 10%+";
            "XF86MonBrightnessDown".action.spawn = spawn "brightnessctl set 10%-";

            "Mod+Shift+Slash".action.show-hotkey-overlay = [];

            "Mod+C".action.close-window = [];
            # "Mod+c".action."center-column" = [];
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
            MOZ_ENABLE_WAYLAND = "1";
          };
        };
      };
    };
  };
}
