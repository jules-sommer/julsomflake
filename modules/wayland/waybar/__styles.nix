{
  lib,
  theme,
  config,
}: let
  inherit (lib) concatStringsSep mkAfter mapAttrsToList;
  makeBackgroundRgba = values: "rgba(${concatStringsSep "," (values |> map (i: toString i))})";

  niriNamedWorkspaces = config.home.programs.niri.settings.workspaces;
  namedWorkspaceHideIndexRules = workspaces:
    workspaces
    |> mapAttrsToList (name: _: ''
      #workspaces button#niri-workspace-${name} span.index {
        display: none;
      }
    '')
    |> concatStringsSep "\n";
in
  {
    font-family ? "JetBrainsMono Nerd Font",
    font-size ? "14px",
    font-weight ? 600,
    background ? [17 17 26 0.95],
    shadow ? [
      "rgba(100, 100, 111, 0.2) 0px 7px 29px 0px"
    ],
    spacing ? "5px",
    spacing-small ? "3px",
    radius ? "8px",
  }:
    mkAfter (concatStringsSep "\n\n" [
      ''
        * {
          font-size: ${font-size};
          font-family: "${font-family}";
        }

        window#waybar, #waybar {
          all: unset;
          padding: 0;
          margin: 0;
        }

        .module {
          background: ${makeBackgroundRgba background};
          border-radius: ${radius};
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


        .module {
          padding: 2px 2px;
        }

        #workspaces button {
          min-width: 10px;
          min-height: 10px;
          border-radius: 9999px;
          padding: 1px 2px;
          margin: 0 6px;
          background-color: ${theme.base0D};
          border: 1px solid ${theme.base0D};
          color: black;
          font-size: 8px;
          font-weight: bold;
        }

        #workspaces:nth-child(1) {
          margin-left: 0;
        }

        #workspaces button span.value {
          color: rgba(255,255,255,0.75);
        }

        #workspaces button.active span.value {
          color: white;
        }

        #workspaces button.empty {
          background-color: transparent;
          border: 1px solid rgba(51, 24, 76, 0.25);
          color: rgba(255,255,255,0.4);
        }

        #workspaces button.active {
          background-color: transparent;
          border: 1px solid ${theme.base0D};
          color: ${theme.base0D};
        }

        #workspaces button.empty {
          background-color: rgba(51, 24, 76, 0.85);
          border: 1px solid rgba(51, 24, 76, 1.0);
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
    ])
