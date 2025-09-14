{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit
    (lib)
    mkEnableOption
    foldr
    ;
  inherit
    (builtins)
    head
    zipAttrsWith
    ;
  cfg = config.local.river;

  modes = config.wayland.windowManager.river.settings.declare-mode;

  mergeWithFn = sets: fn:
    foldr (
      x: y:
        zipAttrsWith fn [
          x
          y
        ]
    ) {}
    sets;

  mergePriority = sets: mergeWithFn sets (name: head);

  home = "/home/jules";
  wallpaperFile = "${home}/060_media/010_wallpapers/zoe-love-bg/zoe-love-4k.png";
  screenshotDir = "${home}/home/jules/060_media/005_screenshots";
  screenshotCmd = ''grim -g "$(slurp -d)" - | tee ${screenshotDir}$(date +%Y-%m-%d_%H-%M-%S).png | wl-copy -t image/png'';
in {
  options.local.river = {
    enable = mkEnableOption "Enable river wm.";
  };

  config = {
    xdg.portal = {
      xdgOpenUsePortal = true;
      config = {
      };
    };

    wayland.windowManager.river = {
      inherit (cfg) enable;
      systemd = {
        enable = true;
        variables = [
          "DISPLAY"
          "WAYLAND_DISPLAY"
          "XDG_CURRENT_DESKTOP"
          "NIXOS_OZONE_WL"
          "XCURSOR_THEME"
          "XCURSOR_SIZE"
        ];
      };
      xwayland.enable = true;
      extraSessionVariables = {
        MOZ_ENABLE_WAYLAND = "1";
      };
      settings = {
        declare-mode = [
          "locked"
          "normal"
          "launch"
          "resize"
          "passthrough"
        ];
        input = {
          pointer-1133-16495-Logitech_MX_Ergo = {
            pointer-accel = 0.2;
            tap = false;
            events = true;
            accel-profile = "adaptive";
          };
        };
        map = mergePriority [
          {
            normal = {
              "Super bracketright" = "focus-view next";
              "Super bracketleft" = "focus-view previous";

              "Super+Shift bracketright" = "focus-output next";
              "Super+Shift bracketleft" = "focus-output previous";

              "Super Return" = "spawn kitty";
              "Super+Shift Return" = "spawn fuzzel";
              "Super Z" = "spawn zen";

              "Super S" = screenshotCmd;
              "Alt+Shift E" = "spawn ${pkgs.emoji-picker}/emoji.sh";

              "Super C" = "close";
              "Super+Shift E" = "exit";

              "Super N" = "focus-view next";
              "Super P" = "focus-view previous";

              "Super+Shift J" = "swap next";
              "Super+Shift K" = "swap previous";

              "Super Period" = "focus-output next";
              "Super Comma" = "focus-output previous";
              "Super H" = "focus-view left";
              "Super J" = "focus-view down";
              "Super K" = "focus-view up";
              "Super L" = "focus-view right";

              "Super+Shift Period" = "send-to-output next";
              "Super+Shift Comma" = "send-to-output previous";

              "Super Space" = "zoom";

              "Super+Shift H" = ''send-layout-cmd rivertile "main-ratio -0.05"'';
              "Super+Shift L" = ''send-layout-cmd rivertile "main-ratio +0.05"'';

              "Super+Alt H" = "move left 50";
              "Super+Alt J" = "move down 50";
              "Super+Alt K" = "move up 50";
              "Super+Alt L" = "move right 50";

              "Super+Alt+Control H" = "snap left";
              "Super+Alt+Control J" = "snap down";
              "Super+Alt+Control K" = "snap up";
              "Super+Alt+Control L" = "snap right";

              "Super+Alt+Shift H" = "resize horizontal -100";
              "Super+Alt+Shift J" = "resize vertical 100";
              "Super+Alt+Shift K" = "resize vertical -100";
              "Super+Alt+Shift L" = "resize horizontal 100";
            };
          }
          {
            launch = {
              "None Return" = "spawn kitty";
              "None Z" = "spawn zen";
              "None J" = "spawn kitty -e joshuto";
              "None Escape" = "enter-mode normal";
            };
            normal = {
              "Super+Shift L" = "enter-mode launch";
            };
          }
        ];
        rule-add = {
          "-app-id" = {
            "'zen-alpha'" = {
              "-title" = {
                "*" = "ssd";
                "*Extention*" = "float";
              };
            };

            "'Jan'" = "ssd";
          };
        };
        keyboard-layout = ''-options "caps:swapescape" "us"'';
        default-layout = "rivertile";
        focus-follows-cursor = "normal";
        border-width = 10;
        set-cursor-warp = "on-output-change";
        set-repeat = "50 200";
        spawn = [
          "kitty"
          "rivertile"
          "wbg ${wallpaperFile}"
          "river-bnf"
        ];
        xcursor-theme = lib.mkForce "Bibata-Modern-Ice 24";
      };
    };
  };
}
