{
  lib,
  helpers,
  config,
  pkgs,
  ...
}: let
  inherit
    (lib)
    types
    mkIf
    ;
  inherit
    (helpers)
    mkOpt
    mkEnableOpt
    enabledIf
    ;

  cfg = config.local.terminal.kitty;
in {
  options.local.terminal.kitty = mkEnableOpt "Kitty configuration.";

  config.local.home.programs.kitty =
    (enabledIf cfg.enable)
    // {
      package = pkgs.kitty;
      font = lib.mkDefault {
        name = "JetBrainsMono Nerd Font";
        package = pkgs.nerd-fonts.jetbrains-mono;
        size = 11;
      };
      environment = {
        KITTY_ENABLE_WAYLAND = "1";
      };
      shellIntegration = {
        mode = "enabled";
        enableFishIntegration = true;
        enableZshIntegration = true;
      };
      keybindings = {
        "alt+1" = "goto_tab 1";
        "alt+2" = "goto_tab 2";
        "alt+3" = "goto_tab 3";
        "alt+4" = "goto_tab 4";
        "alt+5" = "goto_tab 5";
      };
      settings = {
        disable_ligatures = "never";
        linux_display_server = "wayland";
        confirm_os_window_close = lib.mkForce 0;
        window_padding_width = 10;
        tab_title_template = "{index}";
        active_tab_font_style = "bold";
        inactive_tab_font_style = "normal";
        enable_audio_bell = false;
        mouse_hide_wait = 60;
        tab_bar_edge = "bottom";
        allow_remote_control = "yes";
        tab_bar_style = "slant";
        tab_bar_margin_width = 1;
        tab_bar_margin_height = "1.0 1.0";
        transparent = lib.mkForce true;
        scrollback_lines = 15000;
        copy_on_select = "yes";
        background_blur = lib.mkForce 50;
        background_opacity = lib.mkForce 0.9;
      };
    };
}
