{ pkgs, ... }:
{
  programs.waybar = {
    enable = true;
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 30;
        output = [
          "DP-1"
          "HDMI-A-1"
        ];
        modules-left = [
          "river/mode"
          "river"
          "wlr/taskbar"
        ];

        modules-right = [
          "mpd"
          "custom/mymodule#with-css-id"
          "temperature"
          "idle_inhibitor"
          "custom/notification"
          "battery"
          "tray"
          "pulseaudio"
          "custom/quit"
        ];

        modules-center = [
          "clock"
          "custom/hello-from-waybar"
        ];

        clock = {
          format = "󰃭 {:%a, %d %b   %I:%M %p}";
          format-alt = "  {:%I:%M %p}";
          tooltip-format = ''
            <big>{:%I:%M %p}</big>
            <tt><small>{calendar}</small></tt>
          '';
          tooltip = true;
        };

        memory = {
          interval = 5;
          format = " {}%";
          tooltip = true;
        };

        cpu = {
          interval = 5;
          format = " {usage:2}%";
          tooltip = true;
        };

        disk = {
          format = "󰋊 {free} / {total}";
          tooltip = true;
          on-click = "hyprctl dispatch 'exec alacritty -e broot -hipsw'";
        };

        network = {
          format-icons = [
            "󰤯"
            "󰤟"
            "󰤢"
            "󰤥"
            "󰤨"
          ];
          format-ethernet = ": {bandwidthDownOctets}";
          format-wifi = "{icon} {signalStrength}%";
          format-disconnected = "󰤮";
          tooltip = false;
          on-click = "nm-applet";
        };

        "custom/startmenu" = {
          tooltip = false;
          format = "󱄅";
          on-click = "fuzzel";
        };

        "custom/hello-from-waybar" = {
          format = "hello {}";
          max-length = 40;
          interval = "once";
          exec = pkgs.writeShellScript "hello-from-waybar" ''
            echo "from within waybar"
          '';
        };
      };
    };
  };
}
