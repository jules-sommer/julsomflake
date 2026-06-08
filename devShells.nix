{
  pkgs,
  inputs,
  ...
}: let
  inherit (pkgs) mkShell;
  inherit (pkgs.writers) writeFishBin;
  inherit (pkgs.lib) concatLists mapAttrsToList;
  inherit (pkgs.stdenv.hostPlatform) system;
in {
  default = let
    aliases = {
      b = "build";
      bl = "build-legacy";
      rl = "repl";
      c = "check";
      u = "update";
    };
  in
    mkShell {
      nativeBuildInputs = concatLists [
        (aliases
          |> mapAttrsToList (alias: target: writeFishBin alias "exec ${target} $argv"))

        (mapAttrsToList writeFishBin {
          build =
            # fish
            ''
              exec ./build.fish $argv
            '';

          check =
            # fish
            ''
              nix flake check --show-trace --extra-experimental-features pipe-operators
            '';

          repl =
            # fish
            ''
              nix repl --show-trace --extra-experimental-features pipe-operators --file ./repl.nix
            '';

          update =
            # fish
            ''
              nix flake update $argv
            '';

          build-legacy =
            # fish
            ''
              set -l action $argv[1]
              test -n "$action"; or set action switch

              set -l host $argv[2]
              test -n "$host"; or set host $hostname
              test -n "$host"; or set host estradiol

              set -l specialisation $argv[3]
              test -n "$specialisation"; or set specialisation none

              set -l valid_actions switch boot test build dry-build dry-activate edit repl build-vm build-vm-with-bootloader build-image list-generations
              set -l valid_hosts estradiol progesterone

              if not contains -- $action $valid_actions
                  echo "invalid action: $action" >&2
                  exit 1
              end

              if not contains -- $host $valid_hosts
                  echo "invalid host: $host" >&2
                  exit 1
              end

              if test "$specialisation" = none
                  echo "running `$action` on .#$host"
                  doas nixos-rebuild $action --flake ".#$host" --show-trace
              else
                  echo "running `$action` on .#$host (specialisation `$specialisation`)"
                  doas nixos-rebuild $action --flake ".#$host" -c $specialisation --show-trace
              end
            '';
        })

        (with pkgs; [
          alejandra
          neovim
          npins
        ])

        (with inputs; [
          agenix.packages.${system}.default
        ])
      ];
    };

  zig = pkgs.mkShell {
    nativeBuildInputs = with pkgs; [fish];
    packages = concatLists [
      (with pkgs; [
        jq
      ])
      (with inputs; [
        zig.packages.${system}.nightly
        zls.packages.${system}.zls
      ])
    ];
  };
}
