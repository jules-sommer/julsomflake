{
  pkgs,
  helpers,
  config,
  ...
}: let
  inherit (helpers) enabledPred enabled;
  cfg = config.local.shells.zsh;
in {
  config = {
    programs.zsh =
      enabled;

    local.home.programs.zsh = enabledPred cfg.enable {
      package = pkgs.zsh;
      dotDir = "${config.home.xdg.configHome}/zsh";
      setOptions = [
        "EXTENDED_HISTORY"
        "RM_STAR_WAIT"
        "NO_BEEP"
      ];
    };
  };
}
