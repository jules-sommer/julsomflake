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
    enabledPred
    ;

  cfg = config.local.terminal.kitty;
  notify-send = lib.getExe' pkgs.libnotify "notify-send";
  wl-copy = lib.getExe' pkgs.wl-clipboard "wl-copy";
in {
  local.home.programs.kitty = enabledPred cfg.enable {
    package = pkgs.kitty;
    # font = lib.mkDefault {
    #   name = config.local.ui.fonts.defaults.monospace.name;
    #   package = config.local.ui.fonts.defaults.monospace.package;
    #   size = config.local.ui.fonts.sizes.terminal;
    # };
    environment = {
      KITTY_ENABLE_WAYLAND = "1";
    };
    enableGitIntegration = true;
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

      # scroll to the prev/next shell command prompt
      "ctrl+p" = "scroll_to_prompt -1 3"; # jump to previous, showing 3 lines prior
      "ctrl+n" = "scroll_to_prompt 1"; # jump to next

      # alt keymaps, TODO: decide which I prefer.
      "ctrl+b" = "scroll_to_prompt -1 3"; # jump to previous, showing 3 lines prior
      "ctrl+f" = "scroll_to_prompt 1"; # jump to next

      "ctrl+o" = "scroll_to_prompt 0"; # jump to last visited

      "ctrl+equal" = "change_font_size all +2.0";
      "ctrl+minus" = "change_font_size all -2.0";

      "kitty_mod+y" = "launch --type=background --stdin-source=@last_cmd_output ${wl-copy} && ${notify-send} -t 1000 \"kitty\" \"Yanked last output.\"";
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
      listen_on = "unix:/tmp/kitty";
      tab_bar_style = "slant";
      tab_bar_margin_width = 1;
      tab_bar_margin_height = "1.0 1.0";
      scrollback_lines = 15000;
      copy_on_select = "yes";
      background_blur = lib.mkForce 50;
      background_opacity = lib.mkForce 0.9;
    };
  };
}
