{
  inputs,
  config,
  pkgs,
  helpers,
  ...
}: let
  inherit (helpers) mkEnableOpt enabledPred';
  cfg = config.local.terminal.ghostty;
in {
  options.local.terminal.ghostty = mkEnableOpt "Enable Ghostty terminal emulator.";

  config.local.home.programs.ghostty = enabledPred' cfg.enable {
    package = inputs.ghostty.packages.${pkgs.system}.default;
    enableFishIntegration = true;
    enableZshIntegration = true;
    installVimSyntax = true;

    # Configuration written to $XDG_CONFIG_HOME/ghostty/config.
    # See https://ghostty.org/docs/config/reference for more information.
    settings = {
      theme = "catppuccin-mocha";
      font-size = 10;
      keybind = [
        "ctrl+h=goto_split:left"
        "ctrl+l=goto_split:right"
      ];
    };
  };
}
