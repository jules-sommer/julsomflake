{
  helpers,
  config,
  ...
}: let
  inherit (helpers) enabledPred;
  hasJoshuto = config.local.cli.joshuto.enable;
in {
  local.home.programs.joshuto = enabledPred hasJoshuto {
    # keymap = [
    #   {
    #     keys = ["e" "v"];
    #     commands = ["shell $EDITOR %s"];
    #   }
    #   {
    #     keys = ["O"];
    #     commands = ["spawn $SHELL --working-directory %d"];
    #   }
    #   {
    #     keys = ["i"];
    #     commands = ["spawn imv -b checks -t %s"];
    #   }
    # ];

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
}
