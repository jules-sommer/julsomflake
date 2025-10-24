{
  pkgs,
  helpers,
  lib,
  ...
}: let
  inherit (helpers) enabled';
  inherit (lib) attrValues genAttrs cmd spawn;
  getBin = {
    pkg,
    bin_name,
  }: "${pkg}/bin/${bin_name}";

  makoctl = getBin {
    pkg = pkgs.mako;
    bin_name = "makoctl";
  };

  fuzzel = getBin {
    pkg = pkgs.fuzzel;
    bin_name = "fuzzel";
  };

  playerctl = getBin {
    pkg = pkgs.playerctl;
    bin_name = "playerctl";
  };

  pwvucontrol = getBin {
    pkg = pkgs.pwvucontrol;
    bin_name = "pwvucontrol";
  };

  jq = getBin {
    pkg = pkgs.jq;
    bin_name = "jq";
  };

  makeStyle = import ./styles.nix {inherit lib;};
in {
  local.home = {
    stylix.targets = {
      waybar =
        enabled' (genAttrs ["addCss" "enableCenterBackColors" "enableLeftBackColors" "enableRightBackColors"] (_: true));
    };

    programs.waybar = enabled' {
      style = makeStyle {
        font-family = "JetBrainsMono Nerd Font";
        font-size = "14px";
        shadow = [
          "rgba(17, 17, 26, 0.1) 0px 4px 16px"
          "rgba(17, 17, 26, 0.05) 0px 8px 32px"
        ];
        spacing = "5px";
        spacing-small = "3px";
        radius = "8px";
      };
      settings = {
        mainbar = {
          layer = "top";
          spacing = 5;
          height = 0;
          margin-top = 10;
          margin-right = 10;
          margin-bottom = 0;
          margin-left = 10;

          modules-left = [
            "river/tags"
            "river/window"
          ];

          modules-center = [
            "clock"
          ];

          modules-right = [
            "tray"
            "group/system"
            "river/mode"
            "custom/notifications"
            "custom/uptime"
            "custom/music"
          ];

          "custom/notifications" = {
            exec-if = "command -v ${makoctl}";
            exec = "(${makoctl} list | ${jq} -e '.data[] | length > 0' > /dev/null && echo '\nDismiss all notifications\n') || echo '' ";
            format = {};
            on-click = "${makoctl} dismiss -a";
            interval = 3;
          };

          "custom/uptime" = {
            format = "{}";
            format-icon = [
              ""
            ];
            tooltip = false;
            interval = 1600;
            exec = spawn "${pkgs.julespkgs.pretty-uptime}/bin/uptime";
          };

          "custom/music" = {
            format = "  {}";
            escape = true;
            interval = 5;
            tooltip = false;
            exec = "${playerctl} metadata --format='{{ artist }} - {{ title }}'";
            on-click = "${playerctl} play-pause";
            max-length = 50;
          };

          pulseaudio = {
            scroll-step = 5;
            max-volume = 150;
            format = "{icon} {volume}% {format_source}";
            format-bluetooth = "{volume}% {icon} {format_source}";
            on-click = spawn pwvucontrol;
            format-bluetooth-muted = " {icon} {format_source}";
            format-muted = " {format_source}";
            format-source = " {volume}%";
            format-source-muted = "";
            format-icons = {
              headphone = "";
              # hands-free = "";
              # headset = "";
              phone = "";
              portable = "";
              car = "";
              default = [
                ""
                ""
                ""
              ];
            };
          };

          "custom/startmenu" = {
            tooltip = false;
            format = "󱄅";
            exec = spawn fuzzel;
            on-click = spawn fuzzel;
          };

          "group/system" = {
            orientation = "horizontal";
            modules = [
              "cpu"
              "memory"
              "network"
              "wireplumber"
            ];
          };

          "group/power" = {
            orientation = "horizontal";
            drawer = {
              transition-duration = 500;
              children-class = "not-power";
              transition-left-to-right = false;
            };
            modules = [
              "custom/power"
              "custom/quit"
              "custom/lock"
              "custom/reboot"
            ];
          };

          "river/mode" = {
            format = " {}";
          };

          "river/layout" = {
            format = " {}";
            min-length = 4;
            align = "right";
          };

          "river/tags" = {
            num-tags = 5;
          };

          "river/window" = {
            format = "{}";
            max-length = 65;
          };

          tray = {
            tooltip = false;
          };

          clock = {
            format = "{:%A, :%H:%M %p}  ";
            format-alt = "{:%A, %B %d, %Y (%R)}   ";
            tooltip-format = "<tt><big>{calendar}</big></tt>";
            calendar = {
              mode = "year";
              mode-mon-col = 3;
              weeks-pos = "right";
              on-scroll = 1;
              on-click-right = "mode";
              format = {
                months = "<span color='#ffead3'><b>{}</b></span>";
                days = "<span color='#ecc6d9'><b>{}</b></span>";
                weeks = "<span color='#99ffdd'><b>W{}</b></span>";
                weekdays = "<span color='#ffcc66'><b>{}</b></span>";
                today = "<span color='#ff6699'><b><u>{}</u></b></span>";
              };
            };
            actions = {
              on-click-right = "mode";
              on-click-forward = "tz_up";
              on-click-backward = "tz_down";
              on-scroll-up = "shift_up";
              on-scroll-down = "shift_down";
            };
          };

          # clock = {
          #   format = " {:%i:%m %p\t  %a, %d %b %y}";
          #   tooltip = false;
          # };

          wireplumber = {
            format = "{icon}{volume}%";
            format-muted = "󰖁";
            on-click = "helvum";
            format-icons = [
              "󰕿"
              "󰖀"
              "󰕾"
            ];
          };

          cpu = {
            format = "󰻠 {usage}%";
            interval = 2;
            states = {
              critical = 90;
            };
          };

          memory = {
            format = " {percentage}%";
            interval = 2;
            states = {
              critical = 80;
            };
          };

          network = {
            format-wifi = "󰖩";
            format-ethernet = "󰈀";
            format-disconnected = "󰖪";
            tooltip-format-disconnected = "󰖪";
            tooltip-format-wifi = "{essid} ({signalstrength}%) ";
            tooltip-format-ethernet = "{ifname} 󰈀";
            on-click = spawn "nmtui";
            interval = 5;
            tooltip = false;
          };
        };
      };
    };
  };
}
