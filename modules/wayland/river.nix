{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib.attrsets) recursiveUpdate;
  inherit (lib) foldl' listToAttrs enabled' enabled mkCmd getExe getExe' mkEnableOpt mkIf;

  cfg = config.local.wayland.river;

  zen = mkCmd [(getExe pkgs.zen-browser)];
  screenshot = mkCmd [(getExe pkgs.julespkgs.screenshot)];
  emoji-picker = mkCmd ["EMOJI_PICKER_MODE=type;" (getExe pkgs.julespkgs.emoji-picker)];
in {
  options.local.wayland.river = mkEnableOpt "river module";
  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [river-bnf];

    services.greetd.settings.default_session.command = "${pkgs.tuigreet}/bin/tuigreet --cmd ${getExe' pkgs.niri-unstable "niri-session"}";

    programs.river-classic = enabled' {
      package = null;
      xwayland = enabled;
    };

    local.home = {
      xdg.portal.xdgOpenUsePortal = true;
      wayland.windowManager.river = enabled' {
        package = pkgs.river-classic;
        systemd = enabled' {
          variables = [
            "DISPLAY"
            "WAYLAND_DISPLAY"
            "NIXOS_OZONE_WL"
            "XCURSOR_THEME"
            "XCURSOR_SIZE"
          ];
        };
        xwayland = enabled;
        extraSessionVariables = {
          MOZ_ENABLE_WAYLAND = "1";
          XDG_CURRENT_DESKTOP = "river";
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
          map = [
            {
              normal = {
                "Super bracketright" = "focus-view next";
                "Super bracketleft" = "focus-view previous";

                "Super+Shift bracketright" = "focus-output next";
                "Super+Shift bracketleft" = "focus-output previous";

                "Super Return" = "spawn ${pkgs.kitty}/bin/kitty";
                "Super+Shift Return" = "spawn ${pkgs.fuzzel}/bin/fuzzel";

                "Super Z" = zen [];

                "Super S" = screenshot [];

                "Alt E" = emoji-picker [];

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
          ];
          rule-add = let
            genRules = key: names: value: {
              ${key} = listToAttrs (
                map (name: {
                  name = "'${name}'";
                  inherit value;
                })
                names
              );
            };
          in
            foldl' recursiveUpdate {} [
              (genRules "-app-id" ["zen" "zen-alpha" "Jan" "*"] "ssd")
            ];

          keyboard-layout = "us";
          default-layout = "rivertile";
          focus-follows-cursor = "normal";
          border-width = 2;
          set-cursor-warp = "on-output-change";
          set-repeat = "50 200";
          spawn = [
            "${pkgs.kitty}/bin/kitty"
            "rivertile"
            "/home/jules/000_dev/010_zig/river-conf/zig-out/bin/river_conf"

            "river-bnf"
          ];

          xcursor-theme = lib.mkForce "${config.stylix.cursor.name} ${toString config.stylix.cursor.size}";
        };
      };
    };
  };
}
