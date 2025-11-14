{
  local.home = {
    lib,
    pkgs,
    ...
  }: let
    inherit (builtins) toString;
    inherit (lib) range listToAttrs foldl' recursiveUpdate cmd getExe;
    wleave = getExe pkgs.wleave;
    fuzzel = getExe pkgs.fuzzel;
    zen = getExe pkgs.zen-browser;
    kcalc = getExe pkgs.kdePackages.kcalc;
    kitty = getExe pkgs.kitty;
    screenshot = getExe pkgs.julespkgs.screenshot;
    emoji-picker = getExe pkgs.julespkgs.emoji-picker;
  in {
    programs.niri.settings.binds = foldl' recursiveUpdate {} [
      # focus-workspace 0 <-> 9
      (range 0 9
        |> map (num: {
          name = "Mod+${toString num}";
          value = {action.focus-workspace = num;};
        })
        |> listToAttrs)

      # move-column-to-workspace 0 <-> 9
      (range 0 9
        |> map (num: {
          name = "Mod+Shift+${toString num}";
          value = {action.move-column-to-workspace = num;};
        })
        |> listToAttrs)

      # program/app launch shortcut bindings
      {
        "Mod+Z".action.spawn-sh = cmd [zen];
        "Mod+Shift+Return".action.spawn-sh = cmd [fuzzel];
        "Mod+Return".action.spawn-sh = cmd [kitty];

        "Alt+E".action.spawn-sh = cmd [
          "EMOJI_PICKER_MODE=type;"
          emoji-picker
        ];

        "XF86Calculator".action.spawn-sh = cmd [];
        "Mod+M".action.spawn-sh = cmd ["kcalc"];
      }

      # screenshot related binds
      {
        "Mod+S".action.spawn-sh = cmd [screenshot];
        "Mod+Print".action.screenshot = [];
        "Ctrl+Print".action.screenshot-screen = [];
        "Alt+Print".action.screenshot-window = [];
      }

      {
        "Mod+Escape".action.toggle-keyboard-shortcuts-inhibit = [];
        "Mod+Backslash".action.center-column = [];

        "Mod+Space".action.toggle-overview = [];

        "Mod+E" = {
          allow-inhibiting = false;
          action.spawn-sh = cmd [
            wleave
            "-p"
            "layer-shell"
          ];
        };

        "Mod+Shift+E" = {
          allow-inhibiting = false;
          action.quit = [];
        };

        "XF86MonBrightnessUp".action.spawn-sh = cmd ["brightnessctl" "set" "10%+"];
        "XF86MonBrightnessDown".action.spawn-sh = cmd ["brightnessctl" "set" "10%-"];

        "Mod+Shift+Slash".action.show-hotkey-overlay = [];

        "Mod+C".action.close-window = [];

        "Mod+H".action.focus-column-left = [];
        "Mod+J".action.focus-window-down = [];
        "Mod+K".action.focus-window-up = [];
        "Mod+L".action.focus-column-right = [];

        "Mod+Tab".action.focus-window-down-or-column-right = [];
        "Mod+Shift+Tab".action.focus-window-up-or-column-left = [];

        "Mod+bracketleft".action.focus-column-left = [];
        "Mod+bracketright".action.focus-column-right = [];
        "Mod+Shift+bracketleft".action.move-column-left = [];
        "Mod+Shift+bracketright".action.move-column-right = [];

        # focuses monitor left/right
        "Mod+Comma".action.focus-monitor-left = [];
        "Mod+Period".action.focus-monitor-right = [];

        # moves a single window/column to monitor left/right
        "Mod+Shift+Comma".action.move-column-to-monitor-left = [];
        "Mod+Shift+Period".action.move-column-to-monitor-right = [];

        # moves an entire workspace (collection of windows/columns) to another monitor
        "Mod+Ctrl+Comma".action.move-workspace-to-monitor-left = [];
        "Mod+Ctrl+Period".action.move-workspace-to-monitor-right = [];

        "Mod+Shift+H".action.move-column-left = [];
        "Mod+Shift+J".action.move-window-down = [];
        "Mod+Shift+K".action.move-window-up = [];
        "Mod+Shift+L".action.move-column-right = [];

        "Mod+Home".action.focus-column-first = [];
        "Mod+End".action.focus-column-last = [];
        "Mod+Ctrl+Home".action.move-column-to-first = [];
        "Mod+Ctrl+End".action.move-column-to-last = [];

        "Mod+U".action.focus-workspace-up = [];
        "Mod+I".action.focus-workspace-down = [];
        "Mod+Shift+U".action.move-column-to-workspace-up = [];
        "Mod+Shift+I".action.move-column-to-workspace-down = [];
        "Mod+Ctrl+U".action.move-workspace-up = [];
        "Mod+Ctrl+I".action.move-workspace-down = [];

        "Mod+Alt+H".action.consume-or-expel-window-left = [];
        "Mod+Alt+L".action.consume-or-expel-window-right = [];

        "Mod+R".action.switch-preset-column-width = [];
        "Mod+Shift+R".action.switch-preset-window-height = [];

        "Mod+F".action.maximize-column = [];
        "Mod+Shift+F".action.fullscreen-window = [];

        "Mod+Minus".action.set-column-width = "-10%";
        "Mod+Equal".action.set-column-width = "+10%";
        "Mod+Shift+Minus".action.set-window-height = "-10%";
        "Mod+Shift+Equal".action.set-window-height = "+10%";

        "Mod+Shift+P".action.power-off-monitors = [];
      }

      # scrollwheel focus
      {
        "Mod+WheelScrollDown" = {
          cooldown-ms = 150;
          action.focus-workspace-down = [];
        };

        "Mod+WheelScrollUp" = {
          cooldown-ms = 150;
          action.focus-workspace-up = [];
        };

        "Mod+WheelScrollRight" = {
          cooldown-ms = 150;
          action.focus-column-right = [];
        };

        "Mod+WheelScrollLeft" = {
          cooldown-ms = 150;
          action.focus-column-left = [];
        };
      }

      # Volume/player controls
      {
        "XF86AudioRaiseVolume".action.spawn-sh = cmd ["wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "0.01+"];
        "XF86AudioLowerVolume".action.spawn-sh = cmd ["wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "0.01-"];
        "XF86AudioMute".action.spawn-sh = cmd ["wpctl" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle"];

        "F3".action.spawn-sh = cmd ["wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "0.01+"];
        "F2".action.spawn-sh = cmd ["wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "0.01-"];
        "F4".action.spawn-sh = cmd ["wpctl" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle"];

        "XF86AudioPlay".action.spawn = ["playerctl" "play-pause"];
        "XF86AudioPause".action.spawn = ["playerctl" "pause"];
        "XF86AudioNext".action.spawn = ["playerctl" "next"];
        "XF86AudioPrev".action.spawn = ["playerctl" "previous"];
        "XF86AudioStop".action.spawn = ["playerctl" "stop"];
      }
    ];
  };
}
