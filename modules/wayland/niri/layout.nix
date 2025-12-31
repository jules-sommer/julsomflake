{
  lib,
  config,
  ...
}: let
  inherit (lib) enabled' genAttrs disabled';
  theme = config.lib.stylix.colors.withHashtag;
in {
  local.home.programs.niri.settings = {
    prefer-no-csd = true;
    hotkey-overlay.skip-at-startup = true;

    layout = {
      gaps = 16;
      struts = {
        left = -8;
        right = -8;
        top = -12;
        bottom = -8;
      };

      background-color = "transparent";

      always-center-single-column = true;
      center-focused-column = "on-overflow";
      empty-workspace-above-first = true;
      default-column-display = "tabbed";
      focus-ring = disabled' {
        width = 2;
        active.color = "${theme.base0D}ff";
        inactive.color = "${theme.base0D}40";
      };

      border = {
        width = 4;
        active = {
          color = "oklch(65.05904516611996 10.991750441472847 327.99999999999983)";
          # gradient = {
          #   from = "oklch(0.8501 0.1385 299.07 / 95%)";
          #   to = "oklch(0.8918 0.2364 329.26 / 95%)";
          #   angle = 45;
          #   in' = "oklch shorter hue";
          #   relative-to = "workspace-view";
          # };
        };
        inactive = {
          color = "oklch(74.45374586335245 13.45550627732625 320.99999999999983)";

          # gradient = {
          #   from = "oklch(0.9501 0.1039 299.07 / 65%)";
          #   to = "oklch(0.9618 0.1773 329.26 / 65%)";
          #   angle = 45;
          #   in' = "oklch shorter hue";
          #   relative-to = "workspace-view";
          # };
        };
      };

      shadow = enabled' {
        draw-behind-window = true;
        color = "#38165060";
        inactive-color = "#38165040";
        offset.y = 20;
        softness = 40.0;
        spread = -10.0;
      };

      tab-indicator = enabled' {
        hide-when-single-tab = true;
        position = "left";
        gaps-between-tabs = 16;
        corner-radius = 3;
        width = 6;
        place-within-column = true;
        length.total-proportion = 1.0 / 4.0;

        active.gradient = {
          from = "oklch(0.8501 0.1385 299.07 / 95%)";
          to = "oklch(0.8918 0.2364 329.26 / 95%)";
          angle = 45;
          in' = "oklch shorter hue";
          relative-to = "workspace-view";
        };

        inactive.gradient = {
          from = "oklch(0.9501 0.1039 299.07 / 65%)";
          to = "oklch(0.9618 0.1773 329.26 / 65%)";
          angle = 45;
          in' = "oklch shorter hue";
          relative-to = "workspace-view";
        };
      };

      preset-window-heights = [
        {fixed = 720;} # for video's
        {proportion = 8.0 / 21.0;} # 38.1% (golden ratio complement)
        {proportion = 1.0 / 2.0;} # 50%
        {proportion = 13.0 / 21.0;} # 61.9% (golden ratio)
      ];

      preset-column-widths = [
        {proportion = 8.0 / 21.0;} # 38.1% (golden ratio complement)
        {proportion = 1.0 / 2.0;} # 50%
        {proportion = 13.0 / 21.0;} # 61.9% (golden ratio)
      ];

      default-column-width.proportion = 13.0 / 21.0; # ~61.9% (golden ratio)
    };

    overview.workspace-shadow.enable = false;

    layer-rules = [
      {
        matches = [{namespace = "^wallpaper$";}];
        place-within-backdrop = true;
      }
    ];

    window-rules = [
      {
        draw-border-with-background = false;
        geometry-corner-radius = genAttrs ["bottom-left" "bottom-right" "top-left" "top-right"] (_: 8.0);
        clip-to-geometry = true;
        opacity = 1.0;
      }
      {
        matches = [
          {
            app-id = "org.inkscape.Inkscape";
            title = "^Inkscape ";
            is-floating = true;
          }
        ];
        default-column-width.fixed = 700;
        default-window-height.fixed = 800;
      }
      {
        # open-floating windows
        matches = [
          {app-id = "org.kde.kcalc";}
          {app-id = "wev";}
        ];
        open-floating = true;
      }
      {
        matches = [
          {
            app-id = "zen";
            at-startup = true;
          }
        ];

        open-on-workspace = "browser";
      }
      {
        matches = [
          {
            app-id = "Signal";
            at-startup = true;
          }
        ];

        open-on-workspace = "chat";
      }
      {
        matches = [
          {
            app-id = "vesktop";
            at-startup = true;
          }
          {
            app-id = "legcord";
            at-startup = true;
          }
        ];

        open-on-workspace = "chat";
      }

      {
        # Level 3: Neither focused nor active-in-column (most dimmed)
        matches = [{is-focused = false;}];
        excludes = [{is-active-in-column = true;}];
        opacity = 0.80;
      }

      {
        # Level 2: Active in column but not focused (slightly dimmed)
        matches = [{is-active-in-column = true;}];
        excludes = [{is-focused = true;}];
        opacity = 0.96;
      }
    ];
  };
}
