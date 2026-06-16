{config, ...}: let
  stylix = config.stylix;

  c = config.lib.stylix.colors;
  col = base: "#${c.${base}}";
in {
  local.home.programs.kitty.settings = {
    background_blur = 20;
    background_opacity = stylix.opacity.terminal;

    background = col "base00";
    foreground = col "base05";
    selection_background = col "base05";
    selection_foreground = col "base00";
    url_color = col "base04";
    cursor = col "base05";
    cursor_text_color = col "base00";
    color0 = col "base00";
    color1 = col "base08";
    color2 = col "base0B";
    color3 = col "base0A";
    color4 = col "base0D";
    color5 = col "base0E";
    color6 = col "base0C";
    color7 = col "base05";
    color8 = col "base03";
    color9 = col "base08";
    color10 = col "base0B";
    color11 = col "base0A";
    color12 = col "base0D";
    color13 = col "base0E";
    color14 = col "base0C";
    color15 = col "base07";
    active_tab_background = col "base01";
    active_tab_foreground = col "base05";
    inactive_tab_background = col "base00";
    inactive_tab_foreground = col "base04";
    tab_bar_background = col "base00";
    active_border_color = col "base03";
    inactive_border_color = col "base01";
    bell_border_color = col "base0A";

    font_family = config.stylix.fonts.monospace.name;
    font_size = config.stylix.fonts.sizes.terminal;
  };
}
