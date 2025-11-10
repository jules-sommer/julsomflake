{lib}: let
  inherit (lib) concatStringsSep mkAfter;
in
  {
    font-family ? "JetBrainsMono Nerd Font",
    font-size ? "14px",
    font-weight ? 600,
    background ? [17 17 26 0.4],
    # background ? "rgba(17, 17, 26, 0.4)",
    shadow ? [
      "rgba(17, 17, 26, 0.1) 0px 4px 16px"
      "rgba(17, 17, 26, 0.05) 0px 8px 32px"
    ],
    spacing ? "5px",
    spacing-small ? "3px",
    radius ? "8px",
  }:
    mkAfter ''
      * {
        font-size: ${font-size};
        font-family: "${font-family}";
      }

      window#waybar {
        all: unset;
      }

      .modules-left, .modules-center, .modules-right {
        padding: ${spacing};
        margin: ${spacing-small};
        border-radius: ${radius};
        color: white;
        background: rgba(${concatStringsSep "," (background |> map (i: toString i))});
        box-shadow: ${concatStringsSep "," shadow};
      }

      tooltip {
          background: @background;
          color: @color7;
      }

      #clock:hover,
      #custom-notification:hover,
      #bluetooth:hover,
      #network:hover,
      #battery:hover,
      #cpu:hover,
      #tray:hover,
      #system:hover,
      #memory:hover,
      #tags:hover,
      #mode:hover,
      #window:hover,
      #layout:hover,
      #wireplumber:hover,
      #temperature:hover {
        transition: all .3s ease;
        color: @color9;
      }

      #custom-notification {
        padding: 0px ${spacing};
        transition: all .3s ease;
        color: @color7;
      }

      #clock {
        padding: 0px ${spacing};
        color: @color7;
        transition: all .3s ease;
      }

      #workspaces {
        padding: 0px ${spacing};
      }

      #workspaces button {
        all: unset;
        padding: 0px ${spacing};
        color: alpha(@color9, .4);
        transition: all .2s ease;
      }

      #workspaces button:hover {
        color: rgba(0, 0, 0, 0);
        border: none;
        text-shadow: 0px 0px 1.5px rgba(0, 0, 0, .5);
        transition: all 1s ease;
      }

      #workspaces button.active {
        color: @color9;
        border: none;
        text-shadow: 0px 0px 2px rgba(0, 0, 0, .5);
      }

      #workspaces button.empty {
        color: rgba(0, 0, 0, 0);
        border: none;
        text-shadow: 0px 0px 1.5px rgba(0, 0, 0, .2);
      }

      #workspaces button.empty:hover {
        color: rgba(0, 0, 0, 0);
        border: none;
        text-shadow: 0px 0px 1.5px rgba(0, 0, 0, .5);
        transition: all 1s ease;
      }

      #workspaces button.empty.active {
        color: @color9;
        border: none;
        text-shadow: 0px 0px 2px rgba(0, 0, 0, .5);
      }

      #bluetooth {
        padding: 0px ${spacing};
        transition: all .3s ease;
        color: @color7;
      }

      #network {
        padding: 0px ${spacing};
        transition: all .3s ease;
        color: @color7;
      }

      #battery {
        padding: 0px ${spacing};
        transition: all .3s ease;
        color: @color7;
      }

      #battery.charging {
        color: #26A65B;
      }

      #battery.warning:not(.charging) {
        color: #ffbe61;
      }

      #battery.critical:not(.charging) {
        color: #f53c3c;
        animation-name: blink;
        animation-duration: 0.5s;
        animation-timing-function: linear;
        animation-iteration-count: infinite;
        animation-direction: alternate;
      }

      #group-expand {
        padding: 0px ${spacing};
        transition: all .3s ease;
      }

      #custom-expand {
        padding: 0px ${spacing};
        color: alpha(@foreground, .2);
        text-shadow: 0px 0px 2px rgba(0, 0, 0, .7);
        transition: all .3s ease;
      }

      #custom-expand:hover {
        color: rgba(255, 255, 255, .2);
        text-shadow: 0px 0px 2px rgba(255, 255, 255, .5);
      }

      #custom-colorpicker {
        padding: 0px ${spacing};
      }

      #cpu,
      #memory,
      #temperature {
        padding: 0px ${spacing};
        transition: all .3s ease;
        color: @color7;
      }

      #custom-endpoint {
        color: transparent;
        text-shadow: 0px 0px 1.5px rgba(0, 0, 0, 1);
      }

      #tray {
        padding: 0px ${spacing};
        transition: all .3s ease;
      }

      #tray menu * {
        padding: 0px ${spacing};
        transition: all .3s ease;
      }

      #tray menu separator {
        padding: 0px ${spacing};
        transition: all .3s ease;
      }
    ''
