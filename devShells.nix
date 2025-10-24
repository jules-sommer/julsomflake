{
  pkgs,
  inputs,
  system,
  ...
}: let
  inherit (pkgs.lib) foldl';
in {
  default = pkgs.mkShell {
    nativeBuildInputs = with pkgs; [alejandra neovim];
  };
  zig = pkgs.mkShell {
    nativeBuildInputs = with pkgs; [fish];
    packages = foldl' (acc: elem: acc ++ elem) [] [
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
