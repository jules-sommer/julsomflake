{
  packages,
  inputs,
  lib,
}:
let
  inherit (lib) composeManyExtensions;
in
{
  default = _: prev: { };
  unfree = composeManyExtensions [
    (_: prev: {
      inherit (inputs.unfree.legacyPackages.${prev.system}) zsh-abbr masterpdfeditor4 masterpdfeditor;
    })
  ];

  # this overlay is exactly the same as the one provided by sodiboo/niri-flake
  # with the one exception of it's handling of cargo tests. Basically, it defaults
  # to disabling the tests which frequently run into open FD limits.
  niri =
    {
      with_tests ? false,
    }:
    (final: prev: {
      niri-stable = inputs.niri.packages.${prev.system}.niri-stable;
      niri-unstable = inputs.niri.packages.${prev.system}.niri-unstable;
    });

  julespkgs = _: prev: {
    julespkgs = packages.${prev.system};
  };

  from_inputs = composeManyExtensions (
    with inputs;
    [
      niri.overlays.niri
      ghostty.overlays.default
      (_: prev: {
        neovim = neovim.packages.${prev.system}.default;
        nix-init = nix-init.packages.${prev.system}.default;
        zen-browser = julespkgs.packages.${prev.system}.zen-browser__default;
        jan = julespkgs.packages.${prev.system}.jan;
      })
    ]
  );
}
