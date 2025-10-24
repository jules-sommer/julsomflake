{
  self,
  inputs,
  lib,
}: let
  inherit (lib) composeManyExtensions;
in {
  default = _: prev: {};
  unfree = composeManyExtensions [
    (_: prev: {
      inherit (inputs.unfree.legacyPackages.${prev.system}) zsh-abbr masterpdfeditor4 masterpdfeditor claude-code;
    })
  ];

  # this overlay is exactly the same as the one provided by sodiboo/niri-flake
  # with the one exception of it's handling of cargo tests. Basically, it defaults
  # to disabling the tests which frequently run into open FD limits.
  niri = final: prev: {
    niri-stable = inputs.niri.packages.${prev.system}.niri-stable;
    niri-unstable = inputs.niri.packages.${prev.system}.niri-unstable;
  };

  julespkgs = _: prev: {
    julespkgs = inputs.julespkgs.packages.${prev.system} // self.packages.${prev.system};
  };

  from_inputs = composeManyExtensions (
    with inputs; [
      ghostty.overlays.default
      (_: prev: {
        helium = helium.defaultPackage.${prev.system};
        neovim = julespkgs.packages.${prev.system}.neovim;
        zen-browser = julespkgs.packages.${prev.system}.zen-browser__default;
        jan = julespkgs.packages.${prev.system}.jan;
      })
    ]
  );
}
