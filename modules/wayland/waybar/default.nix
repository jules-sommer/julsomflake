{
  pkgs,
  helpers,
  lib,
  config,
  ...
}: let
  inherit (helpers) enabled';
  inherit (lib) genAttrs spawn foldl' recursiveUpdate getBinary optionalAttrs optional concat optionals;

  makoctl = getBinary pkgs.mako;
  fuzzel = getBinary pkgs.fuzzel;
  playerctl = getBinary pkgs.playerctl;
  pwvucontrol = getBinary pkgs.pwvucontrol;
  jq = getBinary pkgs.jq;

  activeCompositor = config.local.wayland.activeCompositor;

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
      style = makeStyle {
        font-family = "JetBrainsMono Nerd Font";
        font-size = "14px";
        shadow = [
          "rgba(100, 100, 111, 0.2) 0px 7px 29px 0px"
        ];
        spacing = "5px";
        spacing-small = "3px";
        radius = "9999px";
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

          (optionalAttrs (activeCompositor == "river") {
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

          (optionalAttrs (activeCompositor == "niri") {
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
            modules-left = foldl' concat [] [
              (optionals (activeCompositor == "river") [
                "river/tags"
                "river/window"
              ])
              (optionals (activeCompositor == "niri") [
                "niri/workspaces"
                "niri/window"
              ])
            ];
          }
          {
            modules-right = foldl' concat [] [
              [
                "tray"
                "wireplumber"
                "network"
                "wireplumber#source"
                "idle_inhibitor"
              ]
              (optionals (activeCompositor == "river") [
                "river/mode"
              ])
              [
                "custom/notifications"
                "custom/uptime"
                "custom/music"
              ]
            ];
          }

          {
            modules-center = [
              "clock"
            ];

            "custom/notifications" = {
              exec-if = "command -v ${makoctl}";
              exec = "makoctl count";
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
              exec = spawn "${pkgs.julespkgs.pretty-uptime}/bin/pretty-uptime";
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
              tooltip = false;
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
              format = "{icon}";
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
