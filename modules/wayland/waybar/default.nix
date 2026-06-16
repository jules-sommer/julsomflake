{
  pkgs,
  helpers,
  lib,
  config,
  ...
}: let
  inherit (helpers) enabled';
  inherit
    (lib)
    genAttrs
    foldl'
    recursiveUpdate
    optional
    getExe
    getExe'
    cmdString
    optionalAttrs
    concatLists
    optionals
    ;

  makoctl = getExe' pkgs.mako "makoctl";
  fuzzel = getExe pkgs.fuzzel;
  playerctl = getExe pkgs.playerctl;
  pwvucontrol = getExe pkgs.pwvucontrol;
  jq = getExe pkgs.jq;

  cfg = config.local.wayland;
  isNiriEnabled = cfg.niri.enable;
  isRiverEnabled = cfg.river.enable;
  isPlasmaEnabled = cfg.river.enable;

  genMargins = sides: val: genAttrs (map (side: "margin-${side}") sides) (_: val);

  makeStyle = import ./__styles.nix {
    inherit lib config;
    theme = config.lib.stylix.colors.withHashtag;
  };

  icons = rec {
    calendar = "󰃭 ";
    clock = " ";
    battery.charging = "󱐋";
    battery.horizontal = [
      " "
      " "
      " "
      " "
      " "
    ];
    battery.vertical = [
      "󰁺"
      "󰁻"
      "󰁼"
      "󰁽"
      "󰁾"
      "󰁿"
      "󰂀"
      "󰂁"
      "󰂂"
      "󰁹"
    ];
    battery.levels = battery.vertical;
    network.disconnected = "󰤮 ";
    network.ethernet = "󰈀 ";
    network.strength = [
      "󰤟 "
      "󰤢 "
      "󰤥 "
      "󰤨 "
    ];
    bluetooth.on = "󰂯";
    bluetooth.off = "󰂲";
    bluetooth.battery = "󰥉";
    volume.source = "󱄠";
    volume.muted = "󰝟";
    volume.levels = [
      "󰕿"
      "󰖀"
      "󰕾"
    ];
    idle.on = "󰈈 ";
    idle.off = "󰈉 ";
    vpn = "󰌆 ";

    notification.red-badge = "<span foreground='red'><sup></sup></span>";
    notification.bell = "󰂚";
    notification.bell-badge = "󱅫";
    notification.bell-outline = "󰂜";
    notification.bell-outline-badge = "󰅸";
  };
in {
  local.home = {
    stylix.targets = {
      waybar = enabled' (foldl' recursiveUpdate {} [
        # we just want stylix to add it's @define-color attributes, and not mess with our actual waybar css
        (genAttrs ["addCss" "enableCenterBackColors" "enableLeftBackColors" "enableRightBackColors"] (_: false))
        {
          font = "monospace";
        }
      ]);
    };

    programs.waybar = enabled' {
      systemd =
        enabled' {
        };
      style = makeStyle {
        font-family = "JetBrainsMono Nerd Font";
        font-size = "14px";
        background = [16 0 24 208];
        shadow = [
          "rgba(100, 100, 111, 0.2) 0px 7px 29px 0px"
        ];
        spacing = 8;
        spacing-small = 4;
        radius = 9999; # basically fully rounded corners
      };
      settings = {
        mainbar = foldl' recursiveUpdate {} [
          {
            layer = "top";
            spacing = 20;
            height = 32;
          }

          (genMargins ["top" "left" "right"] 8)
          {margin-bottom = 8;}

          (optionalAttrs isRiverEnabled {
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
          })

          (optionalAttrs isNiriEnabled {
            "niri/workspaces" = {
              format = ''<span size="small">{icon}</span><span size="small">{index}</span>'';
              format-icons = {
                dev = "󰅩";
                browser = "󰖟";
                chat = "󰭻";
                active = "";
                default = "";
                empty = "";
              };
            };

            "niri/window" = {
              format = "{}";
              max-length = 65;
              rewrite = {
                "\\(.*\\) (.*) - YouTube — Zen Browser" = " $1";
                "(.*) -- Zen Browser" = "󰾔 $1";
                "(.*) - Helium" = "󰾔 $1";
                "(.*) - neovim" = " $1";
                "(.*) - gurlvim" = " $1";
                "(.*) Discord | (.*)" = "  $2";
                "\\(.*\\) Discord \\| (#.*) \\| (.*)" = "  $1 ($2)"; # Server channels
                "\\(.*\\) Discord \\| (.*)" = "  $1"; # DMs and fallback
                "(.*)Signal(.*)" = "󰭻 $2";
              };
            };
          })

          {
            modules-left = concatLists [
              (optional isRiverEnabled "river/tags")
              (optional isNiriEnabled "niri/workspaces")
              ["tray"]
              (optional isRiverEnabled "river/window")
              (optional isNiriEnabled "niri/window")
            ];
          }
          {
            modules-right = concatLists [
              [
                "wireplumber"
                "network"
                "wireplumber#source"
                "idle_inhibitor"
              ]
              (optionals isRiverEnabled [
                "river/mode"
              ])
              [
                "custom/notifications"
                "systemd-failed-units"
                "custom/uptime"
                "custom/music"
              ]
            ];
          }
          {
            modules-center = [
              "clock"
            ];

            systemd-failed-units = {
              "hide-on-ok" = true; # Do not hide if there is zero failed units.
              "format" = "✗ {nr_failed}";
              "format-ok" = "✓";
              "system" = true; # Monitor failed systemwide units.
              "user" = false; # Ignore failed user units.
            };

            "custom/notifications" = {
              exec = cmdString [makoctl "list" "-j" "|" jq "'. | length'"];
              format = {};
              on-click = cmdString [makoctl "dismiss" "-a"];
              interval = 3;
            };

            "custom/uptime" = {
              format = "{}";
              format-icon = [
                ""
              ];
              tooltip = false;
              interval = 1600;
              exec = cmdString "${pkgs.julespkgs.pretty-uptime}/bin/pretty-uptime";
            };

            "custom/music" = {
              format = "  {}";
              escape = true;
              interval = 5;
              tooltip = false;
              exec = "${playerctl} metadata --format='{{ artist }} - {{ title }}'";
              on-click = "${playerctl} play-pause";
              max-length = 30;
            };

            tray = {
              spacing = 16;
              show-passive-items = true;
            };

            clock = {
              format = "${icons.clock} {:%A, :%I:%M %p}";
              format-alt = "${icons.calendar} {:%A, %B %d, %Y (%I:%M %p)}";
              tooltip-format = "<tt><small>{calendar}</small></tt>";
              calendar = {
                mode = "month";
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
              format = "{icon} {volume}%";
              format-muted = "${icons.volume.muted} {volume}%";
              format-icons = icons.volume.levels;
              reverse-scrolling = 1;
              tooltip = false;
            };

            "wireplumber#source" = {
              format = "${icons.volume.source} {node_name}";
              tooltip = false;
            };

            idle_inhibitor = {
              format = "{icon} {status}";
              format-icons = {
                activated = icons.idle.on;
                deactivated = icons.idle.off;
              };
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
              tooltip-format = "{ifname}";
              format-disconnected = icons.network.disconnected;
              format-ethernet = icons.network.ethernet;
              format-wifi = "{icon} {essid}";
              format-icons = icons.network.strength;
            };
          }
        ];
      };
    };
  };
}
