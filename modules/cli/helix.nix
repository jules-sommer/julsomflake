{
  config,
  helpers,
  ...
}: let
  cfg = config.local.cli.helix;
  inherit (helpers) enabledPred;
in {
  local.home.programs.helix = enabledPred cfg.enable {
    enable = true;
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
  };
}
