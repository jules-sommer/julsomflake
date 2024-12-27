{
  lib,
  config,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkOpt
    mkIf
    types
    mkEnableOption
    ;
  cfg = config.local.kitty;
in
{
  options.local.kitty = {
    enable = mkEnableOption "Kitty configuration.";
  };

  config.programs.kitty = mkIf cfg.enable {
    enable = true;
    package = pkgs.kitty;
    font = lib.mkDefault {
      name = "Jetbrains Mono";
      package = pkgs.jetbrains-mono;
      disable_ligatures = "never";
      size = 12;
    };
    environment = {
      KITTY_ENABLE_WAYLAND = "1";
      KITTY_CONFIG_DIRECTORY = "/home/jules/.config/kitty";
    };
    shellIntegration = {
      mode = "enabled";
      enableFishIntegration = true;
    };
    keybindings = {
      ## Tabs
      "alt+1" = "goto_tab 1";
      "alt+2" = "goto_tab 2";
      "alt+3" = "goto_tab 3";
      "alt+4" = "goto_tab 4";
      "alt+5" = "goto_tab 5";
    };
    settings = lib.mkDefault {
      linux_display_server = "wayland";
      confirm_os_window_close = 0;
      window_padding_width = 10;
      tab_title_template = "{index}";
      active_tab_font_style = "normal";
      inactive_tab_font_style = "normal";
      enable_audio_bell = false;
      mouse_hide_wait = 60;
      tab_bar_edge = "bottom";
      allow_remote_control = "yes";
      # enabled_layouts = "splits";
      tab_bar_style = "slant";
      tab_bar_margin_width = 1;
      tab_bar_margin_height = "1.0 1.0";
      transparent = true;
      scrollback_lines = 15000;
      copy_on_select = "yes";
      background_opacity = "0.8";
      background_blur = 50;
      background = "#000000";
    };
  };
}
