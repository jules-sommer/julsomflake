{
  pkgs,
  config,
  lib,
  src,
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
        nfr = "nix-flake-repl";
      };

      home.programs.fish = enabled' {
        package = pkgs.fish;
        plugins = [
          {
            name = "fish-you-should-use";
            src = pkgs.fishPlugins.fish-you-should-use;
          }
          {
            name = "done";
            src = pkgs.fishPlugins.done;
          }
          {
            name = "pure";
            src = pkgs.fishPlugins.pure;
          }
        ];
        functions = {
          fish_greeting.body = "";
          nix-flake-repl.body = ''
            nix repl \
              --expr "let flake = builtins.getFlake \"$(pwd)\"; pkgs = import flake.inputs.nixpkgs { system = builtins.currentSystem; }; in (flake // { inherit pkgs; lib = pkgs.lib; })" \
              --show-trace
          '';
          build.body = builtins.readFile (lib.path.append src "build.fish");
        };
      };
    };
  };
}
