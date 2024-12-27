{ lib, config, ... }:
let
  inherit (lib) mkEnableOption;
  cfg = config.local.river;
in
{
  options.local.river = {
    enable = mkEnableOption "Enable river wm.";
  };

  config = {
    wayland.windowManager.river = {
      inherit (cfg) enable;
      systemd.variables = [
        "-all"
      ];
      systemd.enable = true;
      xwayland.enable = true;
      extraSessionVariables = {
        MOZ_ENABLE_WAYLAND = "1";
      };
      settings = {
        declare-mode = [
          "locked"
          "normal"
          "passthrough"
        ];
        input = {
          pointer-1133-16495-Logitech_MX_Ergo = {
            pointer-accel = 0.2;
            tap = false;
            events = true;
            accel-profile = "adaptive";
            natural-scroll = true;
          };
        };
        map = {
          normal = {
            "Super Return" = "spawn kitty";
            "Super+Shift Return" = "spawn fuzzel";
            "Super Z" = "spawn zen";

            "Super C" = "close";
            "Super Shift E" = "exit";

            # Super+J and Super+K to focus the next/previous view in the layout stack
            "Super N" = "focus-view next";
            "Super P" = "focus-view previous";

            # Super+Shift+J and Super+Shift+K to swap the focused view with the next/previous
            # view in the layout stack
            "Super+Shift J" = "swap next";
            "Super+Shift K" = "swap previous";

            # Super+Period and Super+Comma to focus the next/previous output
            "Super Period" = "focus-output next";
            "Super Comma" = "focus-output previous";
            "Super H" = "focus-view left";
            "Super J" = "focus-view down";
            "Super K" = "focus-view up";
            "Super L" = "focus-view right";

            # Super+Shift+{Period,Comma} to send the focused view to the next/previous output
            "Super+Shift Period" = "send-to-output next";
            "Super+Shift Comma" = "send-to-output previous";

            # Super+Return to bump the focused view to the top of the layout stack
            "Super Space" = "zoom";

            # Super+H and Super+L to decrease/increase the main ratio of rivertile(1)
            "Super+Shift H" = ''send-layout-cmd rivertile "main-ratio -0.05"'';
            "Super+Shift L" = ''send-layout-cmd rivertile "main-ratio +0.05"'';

            # Super+Shift+H and Super+Shift+L to increment/decrement the main count of rivertile(1)
            # "Super+Shift H" = ''send-layout-cmd rivertile "main-count +1"'';
            # "Super+Shift L" = ''send-layout-cmd rivertile "main-count -1"'';

            # Super+Alt+{H,J,K,L} to move views
            "Super+Alt H" = "move left 50";
            "Super+Alt J" = "move down 50";
            "Super+Alt K" = "move up 50";
            "Super+Alt L" = "move right 50";

            # Super+Alt+Control+{H,J,K,L} to snap views to screen edges
            "Super+Alt+Control H" = "snap left";
            "Super+Alt+Control J" = "snap down";
            "Super+Alt+Control K" = "snap up";
            "Super+Alt+Control L" = "snap right";

            # Super+Alt+Shift+{H,J,K,L} to resize views
            "Super+Alt+Shift H" = "resize horizontal -100";
            "Super+Alt+Shift J" = "resize vertical 100";
            "Super+Alt+Shift K" = "resize vertical -100";
            "Super+Alt+Shift L" = "resize horizontal 100";
          };
        };
        rule-add = {
          "-app-id" = {
            "'zen'" = "csd";
            # with title `bar` give client side decorations
            "'bar'" = "csd";
            "'float*'" = {
              "-title" = {
                "'foo'" = "float";
              };
            };
          };
        };
        keyboard-layout = ''-options "caps:swapescape" "us"'';
        default-layout = "rivertile";
        border-width = 10;
        set-cursor-warp = "on-output-change";
        set-repeat = "50 300";
        focus-follows-cursor = true;
        spawn = [
          "zen"
          "kitty"
        ];
        xcursor-theme = lib.mkDefault "Bibata-Modern-Ice 24";
      };
    };
  };
}
