{
  lib,
  config,
  ...
}: let
  inherit (lib) mkIf cmd;
  hasJoshuto = config.local.cli.joshuto.enable;
in {
  local.home = {
    xdg.desktopEntries.joshuto = {
      name = "Joshuto";
      genericName = "File Manager";
      comment = "TUI file manager";
      exec = cmd ["kitty" "joshuto" "%U"];
      icon = "utilities-terminal";
      terminal = true;
      type = "Application";
      categories = ["System" "FileTools" "FileManager"];
      mimeType = ["inode/directory"];
    };
    programs.joshuto = mkIf hasJoshuto {
      settings = {
        xdg_open = true;
        use_trash = false;
        max_preview_size = "32 MB";
        zoxide_update = true;
        custom_commands = [
          {
            name = "rg";
            command = "rg '%text' %s";
          }
        ];

        display = {
          mode = "minimal";
          show_hidden = true;
          line_number_style = "relative";
        };
      };
    };
  };
}
