{
  lib,
  config,
  pkgs,
  helpers,
  ...
}: let
  inherit (helpers) enabled' enabled mkEnableOpt;
  inherit (lib.attrsets) recursiveUpdate;
  inherit (lib) foldl' listToAttrs riverSpawnDefault riverSpawnWithEnv;

  cfg = config.local.wayland.river;

  home = "/home/jules";
  wallpaperFile = "${home}/060_media/010_wallpapers/zoe-love-bg/zoe-love-4k.png";
  screenshotDir = "${home}/060_media/005_screenshots";
in {
  options.local.wayland.river = mkEnableOpt "Enable River.";
  config = {
    programs.river-classic = {
      inherit (cfg) enable;
      package = null;
      xwayland = enabled;

      # TODO: maybe go through these and figure out what's actually needed?
      extraPackages = with pkgs; [
        wayland-protocols
        xdg-desktop-portal-gtk
        xdg-desktop-portal-wlr
        dunst
        scrot
        wlr-randr
        slurp
        grim
        mpv
        river-bnf
        river-tag-overlay
        wshowkeys
        fuzzel
        cliphist
        lswt
        wlrctl
        ydotool
        waylock
        wbg
        brightnessctl
        playerctl
        imv
      ];
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
        xwayland.enable = true;
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

                "Super Z" = riverSpawnDefault "${pkgs.zen-browser}/bin/zen";

                "Super S" =
                  riverSpawnWithEnv {
                    SCREENSHOT_DIR = screenshotDir;
                  }
                  "${pkgs.julespkgs.screenshot}/bin/screenshot";

                "Alt E" =
                  riverSpawnWithEnv {
                    EMOJI_PICKER_MODE = "type";
                  }
                  "${pkgs.julespkgs.emoji-picker}/bin/emoji-picker";

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

          # keyboard-layout = ''-options "caps:swapescape" "us"'';
          keyboard-layout = "us";
          default-layout = "rivertile";
          focus-follows-cursor = "normal";
          border-width = 10;
          set-cursor-warp = "on-output-change";
          set-repeat = "50 200";
          spawn = [
            "${pkgs.kitty}/bin/kitty"
            "rivertile"
            "/home/jules/000_dev/010_zig/river-conf/zig-out/bin/river_conf"
            "${pkgs.wbg}/bin/wbg \"${wallpaperFile}\""
            "river-bnf"
          ];

          xcursor-theme = lib.mkForce "${config.stylix.cursor.name} ${toString config.stylix.cursor.size}";
        };
      };
    };
  };
}
