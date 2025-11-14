{
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf getModulesRecursive enabled' enabled;
  cfg = config.local.shells.fish;
in {
  imports = getModulesRecursive ./. {max-depth = 1;};
  config = mkIf cfg.enable {
    programs.fish = enabled;
    local = {
      shells.aliases = {
        nfr = ''
          nix repl \
            --expr "let flake = builtins.getFlake \"$(pwd)\"; pkgs = import flake.inputs.nixpkgs { system = builtins.currentSystem; }; in flake // { inherit pkgs; lib = pkgs.lib; }" \
            --show-trace
        '';
      };

      home.programs.fish = enabled' {
        package = pkgs.fish;
        plugins = [
          {
            name = "fifc";
            src = pkgs.fishPlugins.fifc;
          }
          {
            name = "sponge";
            src = pkgs.fishPlugins.sponge;
          }
          {
            name = "fish-you-should-use";
            src = pkgs.fishPlugins.fish-you-should-use;
          }
          {
            name = "done";
            src = pkgs.fishPlugins.done;
          }
          {
            name = "tide";
            src = pkgs.fishPlugins.tide;
          }
        ];
        functions.fish_greeting.body = "";
      };
    };
  };
}
