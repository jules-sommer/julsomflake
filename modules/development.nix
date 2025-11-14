{
  lib,
  pkgs,
  config,
  ...
}: let
  inherit (lib) mkEnableOpt enabled mkIf enabled';
  cfg = config.local.development;
in {
  options.local.development =
    mkEnableOpt "Enable development tools and utilities.";

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      neovim
      nixfmt-rfc-style
      nixVersions.latest
      jq
      cached-nix-shell
      nurl
      just
      gitoxide
    ];

    local = {
      shells.aliases.v = "nvim";
      home.programs = {
        claude-code = enabled;
        fzf = enabled;
        ripgrep = enabled;
      };
    };
  };
}
