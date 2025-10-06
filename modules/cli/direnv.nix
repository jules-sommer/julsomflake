{
  pkgs,
  lib,
  ...
}: let
  inherit (lib) enabled enabled' enableShellIntegrations;
in {
  environment.systemPackages = with pkgs; [direnv nix-direnv];
  local.home.programs.direnv =
    # INFO: This excludes fish not because we aren't using the integration with fish, but instead
    # because it is apparently enabled by default. As per [the direnv module within home-manager](https://github.com/nix-community/home-manager/blob/ed10023224107dc8479ead95a448d66f046785e0/modules/programs/direnv.nix#L79C1-L91C12)
    # ```
    # Note, enabling the direnv module will always activate its functionality for Fish since the direnv package automatically gets loaded in Fish.
    # ```
    # trying to set this option will result in an error:
    # ```
    # error: The option `home-manager.users.jules.programs.direnv.enableFishIntegration' is read-only, but it's set multiple times. Definition values:
    # ```
    enabled' (enableShellIntegrations ["zsh" "bash"] true)
    // {
      package = pkgs.direnv;
      silent = false;
      nix-direnv = enabled;
      config = {
        global = {
          bash_path = "${pkgs.bash}/bin/bash";
          load_dotenv = true;
          warn_timeout = "15s";
        };
        whitelist = {
          prefix = [
            "/home/jules/000_dev/010_zig"
            "/home/jules/000_dev/020_rust"
          ];
          exact = [
            "/home/jules/000_dev/000_nix/packages"
            "/home/jules/000_dev/000_nix/julsomflake"
            "/home/jules/000_dev/000_nix/julsomvim"
            "/home/jules/000_dev/000_nix/emoji-picker"
            "/home/jules/000_dev/000_nix/flake-helpers"
            "/home/jules/000_dev/000_nix/home-template-v2"
            "/home/jules/000_dev/000_nix/jan"
            "/home/jules/000_dev/000_nix/pretty-nix"
          ];
        };
      };
    };
}
