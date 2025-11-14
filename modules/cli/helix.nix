{
  config,
  lib,
  ...
}: let
  cfg = config.local.cli.helix;
  inherit (lib) mkEnableOpt mkIf enabled';
in {
  options.local.cli.helix = mkEnableOpt "Whether to enable nnn TUI file manager.";
  config.local.home.programs.helix = mkIf cfg.enable (enabled' {
    settings = {
      editor = {
        line-number = "relative";
        lsp.display-messages = true;
      };
    };
    ignores = [
      ".build/"
      "!.gitignore"
    ];
  });
}
