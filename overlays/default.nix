{
  self,
  inputs,
  lib,
}: let
  inherit (lib) composeManyExtensions;
in {
  default = _: prev: {};
  stable = composeManyExtensions [
    (_: prev: {
      inherit (inputs.nixpkgs-stable.legacyPackages.${prev.system}) protonvpn-gui electron;
    })
  ];
  unfree = composeManyExtensions [
    (_: prev: {
      inherit (inputs.unfree.legacyPackages.${prev.system}) zsh-abbr masterpdfeditor4 masterpdfeditor claude-code libsciter;
    })
  ];

  # this overlay is exactly the same as the one provided by sodiboo/niri-flake
  # with the one exception of it's handling of cargo tests. Basically, it defaults
  # to disabling the tests which frequently run into open FD limits.
  niri = final: prev: {
    niri = inputs.niri.packages.${prev.system}.default;
  };

  julespkgs = _: prev: {
    julespkgs = inputs.julespkgs.packages.${prev.system} // self.packages.${prev.system};
    neovim = inputs.neovim.packages.${prev.system}.default;
  };

  from_inputs = composeManyExtensions (
    with inputs; [
      (_: prev: {
        helium = helium.defaultPackage.${prev.system};
        neovim = julespkgs.packages.${prev.system}.neovim;
        zen-browser = julespkgs.packages.${prev.system}.zen-browser__default;
        jan = julespkgs.packages.${prev.system}.jan;
      })
    ]
  );
}
