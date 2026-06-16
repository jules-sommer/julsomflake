{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.local.terminal.kitty;
  notify-send = lib.getExe' pkgs.libnotify "notify-send";
  wl-copy = lib.getExe' pkgs.wl-clipboard "wl-copy";

  yank-last-output = pkgs.writeShellScriptBin "yank-last-output" ''
    content=$(cat)
    if [ -z "$content" ]; then
      content=$(${lib.getExe' pkgs.wl-clipboard "wl-paste"} --primary --no-newline)
    fi
    printf '%s' "$content" | ${wl-copy}
    preview=$(printf '%s' "$content" | head -c 120 | tr '\n' ' ')
    ${notify-send} -t 2000 "kitty" "Yanked: $preview"
  '';

  fzf-yank-scrollback = pkgs.writeShellScriptBin "fzf-yank-scrollback" ''
    content=$(${lib.getExe pkgs.kitty} @ --to "$KITTY_LISTEN_ON" get-text \
      --match "id:$KITTY_WINDOW_ID" \
      --extent all)

    selected=$(printf '%s' "$content" \
      | ${lib.getExe' pkgs.gawk "awk"} \
          '/❯/{if(block)printf "%s\0",block; block=$0; next} {block=block"\n"$0} END{if(block)printf "%s\0",block}' \
      | ${lib.getExe pkgs.fzf} --read0 --print0 --tac --no-multi \
      | tr -d '\0')

    if [ -n "$selected" ]; then
      printf '%s' "$selected" | ${wl-copy}
      preview=$(printf '%s' "$selected" | head -c 120 | tr '\n' ' ')
      ${notify-send} -t 2000 "kitty" "Yanked: $preview"
    fi
  '';
in {
  local.home.programs.kitty = {
    inherit (cfg) enable;
    enableGitIntegration = true;
    shellIntegration = {mode = "enabled";} // lib.defaultShellIntegrations;

    environment.KITTY_ENABLE_WAYLAND = "1";

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

      "ctrl+y" = "launch --type=background --stdin-source=@last_cmd_output ${lib.getExe yank-last-output}";
      "ctrl+shift+y" = "launch --type=background ${lib.getExe fzf-yank-scrollback}";
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
      listen_on = "unix:/tmp/kitty-{kitty_pid}";
      tab_bar_style = "slant";
      tab_bar_margin_width = 1;
      tab_bar_margin_height = "1.0 1.0";
      scrollback_lines = 15000;
      copy_on_select = "yes";
    };
  };
}
