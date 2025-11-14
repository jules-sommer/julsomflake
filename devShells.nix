{
  pkgs,
  inputs,
  system,
  ...
}: let
  inherit (pkgs.lib) foldl' concat;
in {
  default = pkgs.mkShell {
    nativeBuildInputs = foldl' concat [] [
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
    packages = foldl' concat [] [
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
