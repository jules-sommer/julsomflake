{
  lib,
  helpers,
  ...
}: let
  inherit (helpers) mkEnableOpt enabled;
  inherit (lib) mkOption types;
in {
  imports = [
    ./btop
    ./helix
    ./joshuto
    ./starship
    ./bat.nix
    ./eza.nix
    ./carapace.nix
    ./direnv.nix
    ./nix-index.nix
    ./fastfetch.nix
    ./zoxide.nix
  ];

  # TODO: These are deprecated options from `local.shells.extras`. They
  # may no longer be needed, but figure out what to replace them with if anything.
  # extras = {
  #   direnv = mkEnableOpt "Enable direnv shell integration w/ default options.";
  #   nix-index = mkEnableOpt "Enable nix-index, a file database for nixpkgs, and it's shell integrations w/ default options.";
  # };

  options.local.cli = mkOption {
    type = types.submodule {
      options = {
        joshuto = mkEnableOpt "Enable joshuto file-browser.";
        btop = mkEnableOpt "Enable btop TUI system monitor.";
        helix = mkEnableOpt "Enable helix text editor.";
        starship = mkEnableOpt "Enable starship shell prompt.";
      };
    };

    default = {
      joshuto = enabled;
      btop = enabled;
      helix = enabled;
      starship = enabled;
    };

    description = "Per-user toggles for misc. CLI programs/utils.";
  };
}
