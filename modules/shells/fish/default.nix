{
  pkgs,
  helpers,
  lib,
  config,
  src,
  ...
}: let
  inherit (helpers) enabledPred;
  cfg = config.local.shells.fish;
in {
  config = {
    programs.fish.enable = true;
    local = {
      shells.aliases = {
        nfr = ''
          nix repl \
            --expr "let flake = builtins.getFlake \"$(pwd)\"; pkgs = import flake.inputs.nixpkgs { system = builtins.currentSystem; }; in flake // { inherit pkgs; lib = pkgs.lib; }" \
            --show-trace
        '';
      };

      home = {
        programs.fish = enabledPred cfg.enable {
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

          functions = {
            fish_greeting.body = "";
            mkdirp = {
              description = "Combines functions of touch and mkdir to create directory structure recursively and finally the file itself (with sudo if needed).";
              body = builtins.readFile ./functions/file.fish;
            };

            pretty-uptime = {
              description = "Pretty prints the systems current uptime.";
              body = builtins.readFile (lib.path.append src "./scripts/uptime.fish");
            };

            load-env-file = {
              description = "Takes a path argument for a file (.env or .ini or other textual key-value pair file) and loads each item as a global, exported fish shell variable.";
              body = ''
                set -l file (string trim $argv[1])
                if test -z "$file"
                    set file .env # Default to ".env" if no argument is provided
                end

                if not test -e $file
                    return
                end

                while read -la line
                    if not string match -q "#*" $line
                        set -l key (string trim (string split -m1 "=" $line)[1])
                        set -l value (string trim (string split -m1 "=" $line)[2..])
                        if test -n "$key"
                            echo "Exporting global variable `$key=$value`"
                            set -xg $key (string join "=" $value | string trim)
                        end
                    end
                end <$file
              '';
            };

            show-env = {
              description = "Pretty-print environment with bat";
              body = ''
                printenv -0 \
                  | string split0 \
                  | string replace -r '^(.*?)=(.*)$' '$1 = $2' \
                  | sort \
                  | ${pkgs.bat}/bin/bat -l ini
              '';
            };
          };
        };
      };
    };
  };
}
