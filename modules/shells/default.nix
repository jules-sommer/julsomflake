{
  pkgs,
  helpers,
  config,
  ...
}: let
  inherit (helpers) mkEnableOpt enabled' enabledPred;
  cfg = config.local.shells;
in {
  imports = [
    ./fish
    ./zsh
  ];

  options.local.shells = {
    fish = mkEnableOpt "Enable Fish shell.";
    zsh = mkEnableOpt "Enable Zsh shell.";

    extras = {
      direnv = mkEnableOpt "Enable direnv shell integration w/ default options.";
      nix-index = mkEnableOpt "Enable nix-index, a file database for nixpkgs, and it's shell integrations w/ default options.";
    };
  };

  config = let
    shellIntegrations = {
      enableFishIntegration = true;
      enableZshIntegration = true;
    };
  in {
    programs.direnv = enabledPred cfg.extras.direnv.enable {
      loadInNixShell = true;
    };

    local.home = {
      home.shell =
        {enableShellIntegration = true;}
        // shellIntegrations;

      programs = {
        direnv = enabledPred cfg.extras.direnv.enable {
          package = pkgs.direnv;
          silent = false;
        };

        nix-index = enabledPred cfg.extras.nix-index.enable shellIntegrations;
        zoxide = enabled' shellIntegrations;
        carapace = enabled' shellIntegrations;
      };
    };
  };
}
