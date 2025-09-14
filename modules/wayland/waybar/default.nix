{pkgs, ...}: let
  kitty = cmd: exec "kitty ${cmd}";
  exec = cmd: ''
    riverctl spawn "${cmd}"
  '';
  mkstyle = import ./styles.nix;
in {
  local.home.programs.waybar = {
    enable = true;
    style = mkstyle {
      font-family = "jetbrainsmono nerd font";
      font-size = "14px";
      shadow = "rgba(17, 17, 26, 0.1) 0px 4px 16px, rgba(17, 17, 26, 0.05) 0px 8px 32px";
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
        ];

        pulseaudio = {
          scroll-step = 5;
          max-volume = 150;
          format = "{icon} {volume}% {format_source}";
          format-bluetooth = "{volume}% {icon} {format_source}";
          on-click = kitty "pwvucontrol";
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
          # exec = "rofi -show drun";
          on-click = "rofi -show drun";
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
          format = " {:%i:%m %p\t  %a, %d %b %y}";
          tooltip = false;
        };

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
          on-click = kitty "nmtui";
          interval = 5;
          tooltip = false;
        };
      };
    };
  };
}
