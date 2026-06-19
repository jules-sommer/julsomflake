_: {
  local.home.programs.hyprlock = {
    enable = true;
    settings = {
      general = {
        grace = 2;
        hide_cursor = true;
        ignore_empty_input = true;
      };

      background = [
        {
          path = "screenshot";
          blur_passes = 3;
          blur_size = 8;
        }
      ];

      input-field = [
        {
          size = "300, 300";
          rounding = -1;
          outline_thickness = 4;
          outer_color = "rgba(c4a7e760)";
          inner_color = "rgba(ffffff05)";
          font_color = "rgba(c4a7e7ff)";
          check_color = "rgba(eb6f92ff)";
          fail_color = "rgba(eb6f92ff)";
          fail_text = "<i>$FAIL ($ATTEMPTS)</i>";
          dots_center = true;
          position = "0, 0";
          halign = "center";
          valign = "center";
        }
      ];

      label = [
        {
          text = ''cmd[update:1000] date +"%-I:%M %p"'';
          font_family = "JetBrainsMono NF Light";
          font_size = 48;
          color = "rgba(c4a7e7ff)";
          position = "0, 300";
          halign = "center";
          valign = "center";
        }
      ];
    };
  };
}
